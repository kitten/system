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
      interfaces = {
        external = {
          name = "extern0";
          macAddress = "5c:1b:f4:7f:dc:cd";
        };
        internal = {
          name = "intern0";
          macAddress = "9c:bf:0d:00:23:5d";
          cidr = "10.0.1.1/24";
        };
      };
    };
  };

  system.stateVersion = "24.11";
}

