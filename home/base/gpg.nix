{ lib, helpers, config, ... }:

with lib;
let
  cfg = config.modules.gpg;
  home = "${config.xdg.dataHome}/gnupg";
in {
  options.modules.gpg = {
    enable = mkOption {
      default = true;
      description = "GnuPG";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      homedir = home;
      mutableKeys = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      verbose = true;
      sshKeys = [
        "E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6"
        "75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7"
      ];
    };

    systemd.user.services.gpg-agent.Service.Slice = "session.slice";

    modules.git.signingKey = mkDefault "303B6A9A312AA035";

    age.secrets."pubring.kbx" = {
      symlink = true;
      path = "${home}/pubring.kbx";
      file = ./encrypt/pubring.kbx.age;
    };

    age.secrets."75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key" = {
      symlink = true;
      path = "${home}/private-keys-v1.d/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key";
      file = ./encrypt/75EF1DBB30A59CFB56BCE06A88CCF363DA63B1A7.key.age;
    };

    age.secrets."E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key" = {
      symlink = true;
      path = "${home}/private-keys-v1.d/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key";
      file = ./encrypt/E2BFF19637FDC25A02F45583176FAD1ED1F6BDD6.key.age;
    };

    age.secrets."CA84692E3CC846C8EC7272468E962B63FC599E49.key" = {
      symlink = true;
      path = "${home}/private-keys-v1.d/CA84692E3CC846C8EC7272468E962B63FC599E49.key";
      file = ./encrypt/CA84692E3CC846C8EC7272468E962B63FC599E49.key.age;
    };
  };
}
