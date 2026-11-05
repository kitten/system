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
use std::fs::{self, OpenOptions};
use std::io::{Read, Write};
use std::os::unix::{fs::OpenOptionsExt, net::UnixStream};
use std::path::Path;
use std::time::Duration;
use zeroize::Zeroizing;

const IDENTITY_HRP: &str = "age-plugin-sshagent-";
const MAX_KEY_SIZE: u64 = 1024 * 1024;

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
        .take(MAX_KEY_SIZE + 1)
        .read_to_end(&mut plaintext)
        .map_err(|_| "wrapped credential authentication failed")?;
    if plaintext.len() as u64 > MAX_KEY_SIZE {
        return Err("wrapped credential exceeds size limit".into());
    }
    Ok(plaintext)
}

pub fn run(arguments: &[OsString]) -> Result<()> {
    if arguments.len() != 3 {
        return Err("Usage: git-ssh-access {wrap-keygen|wrap-recipient|wrap|unwrap} source.pub identity.txt; wrap/unwrap read stdin and write stdout".into());
    }
    let public = read_public(Path::new(&arguments[1]))?;
    let socket = std::env::var_os("SSH_AUTH_SOCK").ok_or("SSH_AUTH_SOCK is required")?;
    let mut client = connect(Path::new(&socket))?;
    let path = Path::new(&arguments[2]);
    if arguments[0] == "wrap-keygen" {
        let metadata = Metadata::generate(&public)?;
        let first = metadata.derive(&mut client, &public)?.to_public();
        let second = metadata.derive(&mut client, &public)?.to_public();
        if first != second {
            return Err("source agent did not produce deterministic signatures".into());
        }
        let mut output = OpenOptions::new()
            .write(true)
            .create_new(true)
            .mode(0o600)
            .open(path)?;
        writeln!(output, "# public key: {first}\n{}", metadata.encode()?)?;
        println!("{first}");
        return Ok(());
    }
    let metadata = Metadata::parse(&fs::read_to_string(path)?)?;
    if arguments[0] == "wrap-recipient" {
        println!("{}", metadata.derive(&mut client, &public)?.to_public());
        return Ok(());
    }
    let mut input = Zeroizing::new(Vec::new());
    std::io::stdin()
        .take(MAX_KEY_SIZE + 4096)
        .read_to_end(&mut input)?;
    if input.len() as u64 >= MAX_KEY_SIZE + 4096 {
        return Err("input exceeds credential size limit".into());
    }
    if arguments[0] == "wrap" {
        let identity = metadata.derive(&mut client, &public)?;
        // Reject invalid/encrypted SSH keys before producing a provisioning file.
        let private = ssh_key::PrivateKey::from_openssh(&*input)
            .map_err(|_| "input must be an unencrypted OpenSSH private key")?;
        if private.is_encrypted() {
            return Err("input must be an unencrypted OpenSSH private key".into());
        }
        let ciphertext = age::encrypt(&identity.to_public(), &input)?;
        std::io::stdout().write_all(&ciphertext)?;
    } else if arguments[0] == "unwrap" {
        let plaintext = decrypt(&metadata, &mut client, &public, &input)?;
        std::io::stdout().write_all(&plaintext)?;
    } else {
        return Err("unknown wrapping command".into());
    }
    Ok(())
}
