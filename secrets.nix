let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2TB8awz+vq4oPbzztPLBBRKjgu1LvNoTBLVLgTbBmT"
  ];
in
{
  "./modules/fonts/encrypt/DankMono-Regular.otf.age".publicKeys = keys;
  "./modules/fonts/encrypt/DankMono-Bold.otf.age".publicKeys = keys;
  "./modules/fonts/encrypt/DankMono-Italic.otf.age".publicKeys = keys;

  "./modules/fonts/encrypt/codicon.otf.age".publicKeys = keys;

  "./home/gpg/encrypt/pubring.kbx.age".publicKeys = keys;
  "./home/gpg/encrypt/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key.age".publicKeys = keys;
  "./home/gpg/encrypt/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key.age".publicKeys = keys;
  "./home/gpg/encrypt/CA84692E3CC846C8EC7272468E962B63FC599E49.key.age".publicKeys = keys;

  "./home/npm/encrypt/npmrc.age".publicKeys = keys;
}