let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2TB8awz+vq4oPbzztPLBBRKjgu1LvNoTBLVLgTbBmT"
  ];
in
{
  "./modules/base/encrypt/nix-access-tokens.conf.age".publicKeys = keys;

  "./modules/server/encrypt/tailscale.age".publicKeys = keys;
  "./modules/server/encrypt/rclone.conf.age".publicKeys = keys;
  "./modules/server/encrypt/tangled-knot-ssh.age".publicKeys = keys;

  "./home/fonts/encrypt/DankMono-Regular.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/DankMono-Bold.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/DankMono-Italic.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/codicon.otf.age".publicKeys = keys;
  "./home/fonts/encrypt/faicon.ttf.age".publicKeys = keys;

  "./home/base/encrypt/pubring.kbx.age".publicKeys = keys;
  "./home/base/encrypt/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key.age".publicKeys = keys;
  "./home/base/encrypt/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key.age".publicKeys = keys;
  "./home/base/encrypt/CA84692E3CC846C8EC7272468E962B63FC599E49.key.age".publicKeys = keys;

  "./home/development/encrypt/npmrc.age".publicKeys = keys;

  "./modules/automation/certs/mqtt.key.age".publicKeys = keys;
  "./modules/automation/certs/mqtt.crt.age".publicKeys = keys;

  "./modules/games/palworld/encrypt/palworld-passwd.age".publicKeys = keys;
}
