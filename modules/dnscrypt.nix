{ config, lib, pkgs, ... }: with lib;

let
  inherit (import ../nix/channels.nix) __nixPath;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;

  cfg = config.services.dnscrypt;
in

{
  imports = flatten [
    (optional isDarwin <darwin/modules/launchd>)
  ];

  options.services.dnscrypt = {
    enable = mkEnableOption "dnscrypt-proxy2";

    package = mkOption {
      type = types.path;
      default = pkgs.dnscrypt-proxy2;
      defaultText = "pkgs.dnscrypt-proxy2";
      description = "This option specifies the dnscrypt-proxy package to use.";
    };

    settings = mkOption {
      description = ''
        Attrset that is converted and passed as TOML config file.
        For available params, see: <link xlink:href="https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml"/>
      '';
      example = literalExample ''
        {
          sources.public-resolvers = {
            urls = [ "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md" ];
            cache_file = "public-resolvers.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            refresh_delay = 72;
          };
        }
      '';
      type = types.attrs;
      default = {};
    };

    configFile = mkOption {
      description = ''
        Path to TOML config file. See: <link xlink:href="https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml"/>
        If this option is set, it will override any configuration done in options.services.dnscrypt.settings.
      '';
      example = "/etc/dnscrypt-proxy/dnscrypt-proxy.toml";
      type = types.path;
      default = pkgs.runCommand "dnscrypt-proxy.toml" {
        json = builtins.toJSON cfg.settings;
        passAsFile = [ "json" ];
      } ''
        ${pkgs.remarshal}/bin/json2toml < $jsonPath > $out
      '';
      defaultText = literalExample "TOML file generated from services.dnscrypt.settings";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = [
        cfg.package
      ];
    }

    (optionalAttrs isLinux {
      networking.nameservers = mkDefault [ "127.0.0.1" ];

      systemd.services.dnscrypt= {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          DynamicUser = true;
          ExecStart = "${cfg.package}/bin/dnscrypt-proxy -config ${cfg.configFile}";
          Restart = "always";
        };
      };
    })

    (optionalAttrs isDarwin {
      networking.knownNetworkServices = mkDefault [ "Wi-Fi" ];
      networking.dns = mkDefault [ "127.0.0.1" ];

      launchd.daemons.dnscrypt = {
        serviceConfig.ProgramArguments = [
          "${cfg.package}/bin/dnscrypt-proxy"
          "-config" "${cfg.configFile}"
        ];

        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
      };
    })
  ]);
}
