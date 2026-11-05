//! Version-1 signature derivation compatible with age-plugin-sshagent.
//!
//! The metadata is public. A derivation signature is a long-lived secret: access
//! to the source agent once is sufficient to recover the associated age identity.

use crate::Result;
use bech32::{Bech32, Hrp, primitives::decode::CheckedHrpstring};
use hkdf::Hkdf;
use rand::{RngCore, rngs::OsRng};
use sha2::{Digest, Sha256};
use signature::Verifier;
use ssh_agent_client_rs::Client;
use ssh_key::PublicKey;
use std::ffi::OsString;
use std::fs;
use std::io::{Read, Write};
use std::os::unix::net::UnixStream;
use std::path::Path;
use std::time::Duration;
use zeroize::Zeroizing;

const IDENTITY_HRP: &str = "age-plugin-sshagent-";
pub const MAX_KEY_SIZE: usize = 1024 * 1024;
const MAX_CIPHERTEXT_SIZE: usize = MAX_KEY_SIZE + 4096;
const MAX_BUNDLE_SIZE: usize = MAX_CIPHERTEXT_SIZE + 512;
const BUNDLE_HEADER: &[u8] = b"git-ssh-access wrapped-key v1\n";

pub struct Metadata {
    fingerprint: [u8; 32],
    salt: [u8; 16],
}

pub fn connect(socket: &Path) -> Result<Client> {
    let stream =
        UnixStream::connect(socket).map_err(|_| "cannot connect to forwarded SSH agent")?;
    stream.set_read_timeout(Some(Duration::from_secs(30)))?;
    stream.set_write_timeout(Some(Duration::from_secs(30)))?;
    Ok(Client::with_read_write(Box::new(stream)))
}

impl Metadata {
    pub fn generate(public: &PublicKey) -> Result<Self> {
        require_ed25519(public)?;
        let mut salt = [0; 16];
        OsRng.try_fill_bytes(&mut salt)?;
        Ok(Self {
            fingerprint: fingerprint(public)?,
            salt,
        })
    }

    pub fn parse(input: &str) -> Result<Self> {
        let lines: Vec<_> = input
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty() && !line.starts_with('#'))
            .collect();
        if lines.len() != 1 {
            return Err("expected one public wrapping identity".into());
        }
        let decoded = CheckedHrpstring::new::<Bech32>(lines[0])
            .map_err(|_| "invalid wrapping identity encoding or checksum")?;
        let payload: Vec<_> = decoded.byte_iter().collect();
        if decoded.hrp() != Hrp::parse(IDENTITY_HRP)? || payload.len() != 49 || payload[0] != 1 {
            return Err("unsupported wrapping identity format or version".into());
        }
        Ok(Self {
            fingerprint: payload[1..33].try_into()?,
            salt: payload[33..49].try_into()?,
        })
    }

    pub fn encode(&self) -> Result<String> {
        let mut payload = vec![1];
        payload.extend(self.fingerprint);
        payload.extend(self.salt);
        Ok(bech32::encode_upper::<Bech32>(
            Hrp::parse(IDENTITY_HRP)?,
            &payload,
        )?)
    }

    pub fn matches(&self, public: &PublicKey) -> Result<bool> {
        Ok(self.fingerprint == fingerprint(public)?)
    }

    pub fn derive(&self, client: &mut Client, public: &PublicKey) -> Result<age::x25519::Identity> {
        require_ed25519(public)?;
        if self.fingerprint != fingerprint(public)? {
            return Err("wrapping identity does not match configured source identity".into());
        }
        let mut challenge = b"age-plugin-sshagent/v1/derive\0".to_vec();
        challenge.extend(self.salt);
        let signature = client
            .sign(public, &challenge)
            .map_err(|_| "forwarded agent refused wrapping signature")?;
        public
            .key_data()
            .verify(&challenge, &signature)
            .map_err(|_| "forwarded agent returned an invalid wrapping signature")?;
        // The agent library owns ordinary signature buffers. Memory wiping is
        // best effort; an extra zeroizing copy would not erase those originals.
        let mut info = b"age-plugin-sshagent/v1/x25519\0".to_vec();
        info.extend(self.fingerprint);
        let mut secret = Zeroizing::new([0u8; 32]);
        Hkdf::<Sha256>::new(Some(&self.salt), signature.as_bytes())
            .expand(&info, secret.as_mut())
            .map_err(|_| "wrapping derivation failed")?;
        let encoded = Zeroizing::new(bech32::encode_upper::<Bech32>(
            Hrp::parse("age-secret-key-")?,
            secret.as_ref(),
        )?);
        encoded
            .parse()
            .map_err(|_| "cannot construct derived age identity".into())
    }
}

fn fingerprint(public: &PublicKey) -> Result<[u8; 32]> {
    Ok(Sha256::digest(public.to_bytes()?).into())
}

fn require_ed25519(public: &PublicKey) -> Result<()> {
    if !matches!(public.key_data(), ssh_key::public::KeyData::Ed25519(_)) {
        return Err("wrapping requires an ordinary Ed25519 source identity".into());
    }
    Ok(())
}

pub fn read_public(path: &Path) -> Result<PublicKey> {
    PublicKey::from_openssh(fs::read_to_string(path)?.trim())
        .map_err(|_| "invalid configured SSH public identity".into())
}

pub fn decrypt(
    metadata: &Metadata,
    client: &mut Client,
    public: &PublicKey,
    ciphertext: &[u8],
) -> Result<Zeroizing<Vec<u8>>> {
    let identity = metadata.derive(client, public)?;
    let decryptor = age::Decryptor::new(ciphertext).map_err(|_| "invalid wrapped credential")?;
    let mut reader = decryptor
        .decrypt(std::iter::once(&identity as &dyn age::Identity))
        .map_err(|_| "cannot unlock publication key with the forwarded identity")?;
    // Read through EOF before exposing plaintext, so truncation/authentication
    // failure cannot result in loading a partially verified credential.
    let mut plaintext = Zeroizing::new(Vec::new());
    (&mut reader)
        .take(MAX_KEY_SIZE as u64 + 1)
        .read_to_end(&mut plaintext)
        .map_err(|_| "wrapped credential authentication failed")?;
    if plaintext.len() > MAX_KEY_SIZE {
        return Err("wrapped credential exceeds size limit".into());
    }
    Ok(plaintext)
}

/// The bundle stores only public derivation metadata and encrypted key bytes.
/// The inner age ciphertext and derivation remain reference-plugin compatible.
pub struct Bundle {
    pub metadata: Metadata,
    pub ciphertext: Vec<u8>,
}

pub fn read_bounded(reader: impl Read, limit: usize) -> Result<Zeroizing<Vec<u8>>> {
    let mut bytes = Zeroizing::new(Vec::new());
    reader.take(limit as u64 + 1).read_to_end(&mut bytes)?;
    if bytes.len() > limit {
        return Err("input exceeds credential size limit".into());
    }
    Ok(bytes)
}

pub fn parse_private(plaintext: &[u8]) -> Result<ssh_key::PrivateKey> {
    let key = ssh_key::PrivateKey::from_openssh(plaintext)
        .map_err(|_| "credential must be an unencrypted OpenSSH private key")?;
    if key.is_encrypted() {
        return Err("credential must be an unencrypted OpenSSH private key".into());
    }
    Ok(key)
}

impl Bundle {
    pub fn wrap(client: &mut Client, source: &PublicKey, plaintext: &[u8]) -> Result<Self> {
        if plaintext.len() > MAX_KEY_SIZE {
            return Err("input exceeds credential size limit".into());
        }
        drop(parse_private(plaintext)?);
        let metadata = Metadata::generate(source)?;
        let identity = metadata.derive(client, source)?;
        if identity.to_public() != metadata.derive(client, source)?.to_public() {
            return Err("source agent did not produce deterministic signatures".into());
        }
        Ok(Self {
            metadata,
            ciphertext: age::encrypt(&identity.to_public(), plaintext)?,
        })
    }

    pub fn read(reader: impl Read) -> Result<Self> {
        let bytes = read_bounded(reader, MAX_BUNDLE_SIZE)?;
        let payload = bytes
            .strip_prefix(BUNDLE_HEADER)
            .ok_or("unsupported wrapped-key bundle format or version")?;
        let newline = payload
            .iter()
            .position(|byte| *byte == b'\n')
            .filter(|position| *position <= 256)
            .ok_or("missing wrapped-key derivation metadata")?;
        let metadata = Metadata::parse(std::str::from_utf8(&payload[..newline])?)?;
        let ciphertext = &payload[newline + 1..];
        if ciphertext.is_empty() || ciphertext.len() > MAX_CIPHERTEXT_SIZE {
            return Err("invalid wrapped-key ciphertext size".into());
        }
        Ok(Self {
            metadata,
            ciphertext: ciphertext.to_vec(),
        })
    }

    pub fn write(&self, mut output: impl Write) -> Result<()> {
        if self.ciphertext.is_empty() || self.ciphertext.len() > MAX_CIPHERTEXT_SIZE {
            return Err("invalid wrapped-key ciphertext size".into());
        }
        output.write_all(BUNDLE_HEADER)?;
        writeln!(output, "{}", self.metadata.encode()?)?;
        output.write_all(&self.ciphertext)?;
        Ok(())
    }

    pub fn unlock(&self, client: &mut Client) -> Result<Zeroizing<Vec<u8>>> {
        let mut source = None;
        for identity in client
            .list_all_identities()
            .map_err(|_| "cannot list forwarded SSH identities")?
        {
            if let ssh_agent_client_rs::Identity::PublicKey(public) = identity
                && self.metadata.matches(&public)?
            {
                if source.is_some() {
                    return Err("forwarded agent offered duplicate source identities".into());
                }
                source = Some(public.into_owned());
            }
        }
        let source =
            source.ok_or("approved source identity is not available in the forwarded agent")?;
        decrypt(&self.metadata, client, &source, &self.ciphertext)
    }
}

fn source_identity(client: &mut Client) -> Result<PublicKey> {
    let mut source = None;
    for identity in client
        .list_all_identities()
        .map_err(|_| "cannot list SSH agent identities")?
    {
        if let ssh_agent_client_rs::Identity::PublicKey(public) = identity
            && require_ed25519(&public).is_ok()
        {
            if source.is_some() {
                return Err(
                    "multiple supported SSH agent identities; select one with -i public-key-file"
                        .into(),
                );
            }
            source = Some(public.into_owned());
        }
    }
    source.ok_or_else(|| "no supported Ed25519 identity is available in the SSH agent".into())
}

pub const USAGE: &str = "Usage:\n  git-ssh-access wrap [-i public-key-file] < private-key > wrapped-key\n  git-ssh-access unwrap < wrapped-key\n\nThe source identity must be available through SSH_AUTH_SOCK.\nWithout -i, wrap requires exactly one supported Ed25519 identity in the agent.\nGit transport and forced-command modes are configured by the Nix module.";

pub fn run(arguments: &[OsString]) -> Result<()> {
    enum Operation<'a> {
        Wrap(Option<&'a Path>),
        Unwrap,
    }
    let operation = match arguments {
        [command] if command == "wrap" => Operation::Wrap(None),
        [command, flag, path] if command == "wrap" && flag == "-i" => {
            Operation::Wrap(Some(Path::new(path)))
        }
        [command] if command == "unwrap" => Operation::Unwrap,
        [command, flag]
            if (command == "wrap" || command == "unwrap") && (flag == "--help" || flag == "-h") =>
        {
            println!("{USAGE}");
            return Ok(());
        }
        _ => return Err(USAGE.into()),
    };
    let socket = std::env::var_os("SSH_AUTH_SOCK").ok_or("SSH_AUTH_SOCK is required")?;
    let mut client = connect(Path::new(&socket))?;
    match operation {
        Operation::Wrap(path) => {
            let source = match path {
                None => source_identity(&mut client)?,
                Some(path) => read_public(path)?,
            };
            let plaintext = read_bounded(std::io::stdin(), MAX_KEY_SIZE)?;
            Bundle::wrap(&mut client, &source, &plaintext)?.write(std::io::stdout())?;
        }
        Operation::Unwrap => {
            let bundle = Bundle::read(std::io::stdin())?;
            let plaintext = bundle.unlock(&mut client)?;
            drop(parse_private(&plaintext)?);
            std::io::stdout().write_all(&plaintext)?;
        }
    }
    Ok(())
}
