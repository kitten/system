{ config, pkgs, ... } @ inputs:

{
  age.secrets."pubring.kbx" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.gnupg/pubring.kbx";
    file = ./encrypt/pubring.kbx.age;
  };

  age.secrets."75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.gnupg/private-keys-v1.d/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key";
    file = ./encrypt/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key.age;
  };

  age.secrets."E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.gnupg/private-keys-v1.d/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key";
    file = ./encrypt/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key.age;
  };

  age.secrets."CA84692E3CC846C8EC7272468E962B63FC599E49.key" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.gnupg/private-keys-v1.d/CA84692E3CC846C8EC7272468E962B63FC599E49.key";
    file = ./encrypt/CA84692E3CC846C8EC7272468E962B63FC599E49.key.age;
  };

  home.file.".gnupg/sshcontrol".text = ''
    E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6
    75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7
  '';
}
