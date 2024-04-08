{ config, ... } @ inputs:

{
  age.secrets."npmrc" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.npmrc";
    file = ./encrypt/npmrc.age;
  };

  home.file.".yarnrc".text = ''
    disable-self-update-check true
    email phil@kitten.sh
    username philpl
  '';

  home.file.".bunfig.toml".text = ''
    telemetry = false

    [install]
    auto = "disable"
    globalDir = "~/.local/share/bun/global"
    globalBinDir = "~/.local/share/bun"

    [install.cache]
    dir = "~/.cache/bun/install/cache"
  '';
}
