{ lib, pkgs, config, user, ... }:

with lib;
let
  inherit (generators) toLua;
  cfg = config.modules.desktop;
in {
  options.modules.desktop.services = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable services.";
      type = types.bool;
    };

    pipewire = {
      enable = mkOption {
        default = cfg.services.enable;
        example = true;
        description = "Whether to enable Pipewire low latency.";
        type = types.bool;
      };

      lowLatency = mkOption {
        default = cfg.services.pipewire.enable;
        example = true;
        description = "Whether to enable Pipewire low latency.";
        type = types.bool;
      };

      quantum = mkOption {
        description = "Minimum quantum to set";
        type = types.int;
        default = 64;
        example = 32;
      };

      rate = mkOption {
        description = "Rate to set";
        type = types.int;
        default = 48000;
        example = 96000;
      };
    };
  };

  config = mkIf cfg.services.enable {
    users.users."${user}".extraGroups = [ "video" ];

    services = {
      hardware.bolt.enable = true;
      printing.enable = true;
      colord.enable = true;
      fwupd.enable = true;

      pipewire = let
        quantum = cfg.services.pipewire.quantum;
        rate = cfg.services.pipewire.rate;
        qr = "${toString quantum}/${toString rate}";
      in {
        enable = cfg.services.pipewire.enable;
        pulse.enable = true;
        jack.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };

        # write extra config
        extraConfig.pipewire = mkIf cfg.services.pipewire.lowLatency {
          "99-lowlatency" = {
            context = {
              properties.default.clock.min-quantum = quantum;
              modules = [
                {
                  name = "libpipewire-module-rtkit";
                  flags = ["ifexists" "nofail"];
                  args = {
                    nice.level = -15;
                    rt = {
                      prio = 88;
                      time.soft = 200000;
                      time.hard = 200000;
                    };
                  };
                }
                {
                  name = "libpipewire-module-protocol-pulse";
                  args = {
                    server.address = ["unix:native"];
                    pulse.min = {
                      req = qr;
                      quantum = qr;
                      frag = qr;
                    };
                  };
                }
              ];

              stream.properties = {
                node.latency = qr;
                resample.quality = 1;
              };
            };
          };
        };

        wireplumber = {
          enable = true;
          configPackages = let
            # generate "matches" section of the rules
            matches = toLua {
              multiline = false; # looks better while inline
              indent = false;
            } [[["node.name" "matches" "alsa_output.*"]]]; # nested lists are to produce `{{{ }}}` in the output

            # generate "apply_properties" section of the rules
            apply_properties = toLua {} {
              "audio.format" = "S32LE";
              "audio.rate" = rate * 2;
              "api.alsa.period-size" = 2;
            };
          in [
            (pkgs.writeTextDir "share/lowlatency.lua.d/99-alsa-lowlatency.lua" ''
              -- Generated by nix-gaming
              alsa_monitor.rules = {
                {
                  matches = ${matches};
                  apply_properties = ${apply_properties};
                }
              }
            '')
          ];
        };
      };
    };
  };
}
