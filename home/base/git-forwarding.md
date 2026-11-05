# Git publication through forwarded identities

`git send` forwards the source SSH agent only to its receiving connection. Agent
accounts publish to origin by default; operator accounts retain local-only sends.
Agent accounts can use `--local-only` to stop at receipt. `git receive` and global
SSH forwarding settings are unchanged.

Configure the receiving account's `modules.git.sshAccess.forwardingIdentities`.
The incoming connection must use the module's Git-only forced command;
`authorizedKeys` controls incoming access separately from the forwarded identities.
Exactly one configured identity must be offered by the forwarded agent. A direct
entry contains only `publicKey`: onward GitHub authentication uses that identity
through the source agent, retaining its GPG unlock/confirmation requirements.

An unattended entry supplies four fields:

```nix
modules.git.sshAccess.forwardingIdentities = [
  {
    publicKey = "ssh-ed25519 ... approved source agent";
    wrappedKey = config.age.secrets.git-publication.path;
    ageIdentity = "AGE-PLUGIN-SSHAGENT-1...";
    publicationPublicKey = "ssh-ed25519 ... GitHub publication";
  }
];

age.secrets.git-publication.file = ./encrypt/git-publication.age;
```

The agenix secret's payload is an **already wrapped** private key. Never add an
unwrapped copy or an unlocking secret as another agenix secret. Public SSH keys
and wrapping metadata may be stored in Nix configuration; private material must
remain outside the Nix store. Add the outer `.age` file to `secrets.nix` following
the existing recipient conventions. No real credential is generated or enrolled
by enabling this module.

## Provisioning

On a trusted machine with only the approved ordinary Ed25519 source identity
available through `SSH_AUTH_SOCK`, generate public wrapping metadata:

```sh
git-ssh-access wrap-keygen source.pub identity.txt
```

The command refuses to overwrite `identity.txt`. It requests the derivation twice
and verifies reproducibility; stdout is the public age recipient. The metadata
file contains the source fingerprint and a random salt, not an unlocking secret.

Create a separate publication SSH key using `ssh-keygen`. Register its public key
with the intended GitHub account. Wrap its unencrypted OpenSSH private key:

```sh
git-ssh-access wrap source.pub identity.txt < publication > publication.wrapped
```

Store `publication.wrapped` as the payload of the new agenix secret. Copy the
single `AGE-PLUGIN-SSHAGENT-1...` line from `identity.txt` into `ageIdentity`, and
configure both SSH public keys. On the receiving account, agenix must install
the inner wrapped bytes, not the plaintext key. Verify the provisioned bytes can
be unwrapped and that their public key matches the registered publication key:

```sh
git-ssh-access unwrap source.pub identity.txt < publication.wrapped |
  ssh-keygen -y -f /dev/stdin
```

Run this verification only where the source agent is available. After verifying
the agenix-provisioned payload, discard the original plaintext private key and
temporary copies. The metadata and wrapped payload are sufficient for future
sends with the source agent; the original need not be retained.

`wrap-recipient source.pub identity.txt` reproduces the public age recipient.
`unwrap` writes plaintext to stdout and is intended for explicit provisioning
verification/pipelines, never logs or persistent key files.

## Runtime and boundaries

The Rust CLI implements the version-1 derivation used by
[age-plugin-sshagent](https://github.com/unidoc/age-plugin-sshagent/tree/e8774a9833f90a4b06e29d69f0cf9ad5be0439c4): sign
`age-plugin-sshagent/v1/derive || NUL || salt`, verify the Ed25519 signature, then
HKDF-SHA256 the signature with that salt and
`age-plugin-sshagent/v1/x25519 || NUL || source fingerprint` as context. The result
is an X25519 age identity. The Rust age library handles file encryption; the Go
plugin and external age executable are not runtime dependencies. The ignored
reference interoperability test accepts a separately pinned plugin executable.

Only ordinary Ed25519 source identities are accepted for wrapping. Hardware-key
variants and other algorithms are rejected. Agents that require confirmation or
restrict arbitrary signing may prevent unattended derivation. Personal direct
authentication does not have this Ed25519-only restriction.

The receiver validates the entire decrypted credential and expected public key
before loading it directly through the Rust agent client into a private temporary
SSH agent with a default 60-second key lifetime. No receiver-side `ssh-add`
subprocess or plaintext-key pipe is needed.
OpenSSH uses that agent and the explicit publication public key, with no personal
SSH configuration, credential fallback, multiplexing, or onward agent forwarding.
A supervisor owns both outbound SSH and the temporary agent. A separate control
socket detects caller death without consuming Git's protocol streams. Completion,
interruption, or caller death stops SSH and the agent before the supervisor's
`tempfile` directory is removed. Direct-identity sessions also supervise SSH while
leaving the source agent intact. Both transport and supervisor have bounded
lifetimes. Each preflight/push
connection obtains its own credential and agent. Host keys must already be trusted
in the receiving account's usual known_hosts file.

Agent-account sends create a short-lived source agent containing their configured
file-backed SSH key. Ordinary Git continues using the file identity without an
agent. Personal sends use the existing source agent. Inbound forwarded sockets
are already preserved by the pinned Home Manager shell initialization.

Operator files alone cannot unlock the wrapped key. A hostile operator-account
process present during a send can capture the forwarded signing capability or
decrypted credential. A captured derivation signature remains an unlocking secret
for that metadata; this does not establish per-command isolation or an online-only
authorization guarantee. Keep the existing forced-command, branch/ref, and
repository restrictions; GitHub credential authority is separate from those local
checks.

Rotate source identities by rewrapping while the old identity is still available,
or generate and register a replacement publication key. If the source identity is
lost after the original plaintext was discarded, agenix can recover only the
wrapped payload. Revoke the old GitHub credential when replacing it.

## Validation

Use the pinned Nix toolchain to run `cargo test` and `cargo clippy --all-targets --
-D warnings` in `git-ssh-access`, or build `git-ssh-access/package.nix` through
`pkgs.callPackage`. Integration tests use disposable keys and isolated agents.
For the optional reference test, set `GIT_FORWARD_TEST_PLUGIN` to the pinned
plugin binary and run `cargo test interoperates_with_reference_plugin -- --ignored`.
