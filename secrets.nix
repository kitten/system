let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2TB8awz+vq4oPbzztPLBBRKjgu1LvNoTBLVLgTbBmT"
  ];
in
{
  "./modules/base/encrypt/nix-access-tokens.conf.age".publicKeys = keys;

  "./modules/desktop/fonts/encrypt/DankMono-Regular.otf.age".publicKeys = keys;
  "./modules/desktop/fonts/encrypt/DankMono-Bold.otf.age".publicKeys = keys;
  "./modules/desktop/fonts/encrypt/DankMono-Italic.otf.age".publicKeys = keys;
  "./modules/desktop/fonts/encrypt/codicon.otf.age".publicKeys = keys;
  "./modules/desktop/fonts/encrypt/faicon.ttf.age".publicKeys = keys;

  "./modules/server/encrypt/tailscale.age".publicKeys = keys;
  "./modules/server/encrypt/rclone.conf.age".publicKeys = keys;

  "./home/gpg/encrypt/pubring.kbx.age".publicKeys = keys;
  "./home/gpg/encrypt/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key.age".publicKeys = keys;
  "./home/gpg/encrypt/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key.age".publicKeys = keys;
  "./home/gpg/encrypt/CA84692E3CC846C8EC7272468E962B63FC599E49.key.age".publicKeys = keys;

  "./home/js/encrypt/npmrc.age".publicKeys = keys;
}
