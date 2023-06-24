{ lib, pkgs, ... } @ inputs:

let
  inherit (import ../../../lib/colors.nix inputs) colors shell lightStroke darkStroke mkScssSyntax;
in {
  home.packages = [ pkgs.eww-wayland ];

  xdg.configFile."eww/_colors.scss".text = mkScssSyntax (colors // {
    shell.gui = shell;
    lightStroke.gui = lightStroke;
    darkStroke.gui = darkStroke;
  });

  xdg.configFile."eww/_variables.yuck".text = "";

  xdg.configFile.eww = {
    recursive = true;
    source = lib.cleanSourceWith {
      filter = name: _type: !(lib.hasSuffix ".nix" (baseNameOf (toString name)));
      src = lib.cleanSource ./.;
    };
  };

  systemd.user.services.eww = let
    dependencies = with pkgs; [ eww-wayland bash ];
  in {
    Unit = {
      Description = "ElKowars wacky widgets";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };

    Service = {
      Environment = "PATH=${lib.makeBinPath dependencies}";
      ExecStart = "${pkgs.eww-wayland}/bin/eww daemon --no-daemonize";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };
  };
}
