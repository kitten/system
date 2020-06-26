let
  inherit (import ../../nix/secrets.nix) readSecretFile;
in {
  home.file.".gnupg/pubring.kbx".source =
    readSecretFile ../../assets/pubring.kbx;
  home.file.".gnupg/private-keys-v1.d/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key".source =
    readSecretFile ../../assets/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key;
  home.file.".gnupg/private-keys-v1.d/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key".source =
    readSecretFile ../../assets/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key;
  home.file.".gnupg/private-keys-v1.d/CA84692E3CC846C8EC7272468E962B63FC599E49.key".source =
    readSecretFile ../../assets/CA84692E3CC846C8EC7272468E962B63FC599E49.key;
}
