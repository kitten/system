{ lib, helpers, config, pkgs, ... }:

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
      mutableTrust = true;
      publicKeys = [
        { source = ./assets/pubring.asc; trust = "ultimate"; }
      ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      verbose = true;
      sshKeys = [ "DDA4674BEB2FBE8A1EFB6F542FA66EDC2BFD54F5" ];
      defaultCacheTtl = 1;
      defaultCacheTtlSsh = 1;
      maxCacheTtl = 10;
      maxCacheTtlSsh = 10;
      noAllowExternalCache = true;
      pinentry = helpers.mkIfDarwin {
        package = pkgs.pinentry-touchid;
        program = "pinentry-touchid";
      };
    };

    systemd.user.services.gpg-agent.Service.Slice = "session.slice";

    modules.git.signingKey = mkDefault "4EAF3D43CDBB01C9";

    home.file."${home}/sshcontrol".text = "DDA4674BEB2FBE8A1EFB6F542FA66EDC2BFD54F5";

    # ed25519 2025-09-06 [C]
    age.secrets."147CBD801C5E0D0C27DD006653D3D96FF952F652.key" = {
      symlink = true;
      path = "${home}/private-keys-v1.d/147CBD801C5E0D0C27DD006653D3D96FF952F652.key";
      file = ./encrypt/147CBD801C5E0D0C27DD006653D3D96FF952F652.key.age;
    };
    # ed25519 2025-09-06 [SA]
    age.secrets."DDA4674BEB2FBE8A1EFB6F542FA66EDC2BFD54F5.key" = {
      symlink = true;
      path = "${home}/private-keys-v1.d/DDA4674BEB2FBE8A1EFB6F542FA66EDC2BFD54F5.key";
      file = ./encrypt/DDA4674BEB2FBE8A1EFB6F542FA66EDC2BFD54F5.key.age;
    };
    # cv25519 2025-09-06 [E]
    age.secrets."F6BECEF8FA360886C588883F90AD03CBE7B6450A.key" = {
      symlink = true;
      path = "${home}/private-keys-v1.d/F6BECEF8FA360886C588883F90AD03CBE7B6450A.key";
      file = ./encrypt/F6BECEF8FA360886C588883F90AD03CBE7B6450A.key.age;
    };
  };
}
