{ user, ... }:

{
  imports = [
    ./hardware.nix
  ];

  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$DEmCOeiSFe6ymGox$WMWddbT9PkkfDT6JS4WuJsM3mQHI0e9kg0t42UowO79dWAcSU0K//KKlcebSosoMRz5mUEw5TFvbrv1aRHqYa/";
  };

  modules = {
    router = {
      enable = true;
      ipv6 = true;
      interfaces = {
        external = {
          name = "extern0";
          macAddress = "5c:1b:f4:7f:dc:cd";
          adoptMacAddress = "64:20:9f:16:70:a6";
        };
        internal = {
          name = "intern0";
          macAddress = "9c:bf:0d:00:23:5d";
          cidr = "10.0.0.1/24";
        };
      };
      leases = [
        { macAddress = "98:ed:7e:c6:57:b2"; ipAddress = "10.0.0.102"; } # eero router
        { macAddress = "c4:f1:74:51:4c:f2"; ipAddress = "10.0.0.124"; } # eero router
        { macAddress = "5c:61:99:7a:16:40"; ipAddress = "10.0.0.103"; } # brother printer
      ];
      nftables.blockForward = [
        "ec:e5:12:1d:23:40" # tado
      ];
    };
    automation = {
      enable = true;
      mqtt.enable = true;
      zigbee = {
        enable = true;
        serialPort = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_fcea8ceb8612ec11ab4e23c7bd930c07-if00-port0";
      };
      homebridge.enable = true;
    };
    server = {
      enable = true;
      tailscale.enable = true;
      caddy.enable = true;
      vaultwarden.enable = true;
    };
    games = {
      enable = true;
      palworld = {
        enable = true;
        public = true;
        ip = "51.38.68.193";
        settings = {
          ServerName = "London Boroughs";
          AllowConnectPlatform = "Xbox";
          PalEggDefaultHatchingTime = 1;
          GuildPlayerMaxNum = 10;
          bShowPlayerList = true;
          bEnableNonLoginPenalty = false;
          bUseAuth = false;
        };
      };
    };
  };

  system.stateVersion = "24.11";
}

