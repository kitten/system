{ ... }:

{
  modules = {
    development.enable = true;
    apps = {
      enable = true;
      wezterm.enable = true;
      firefox.enable = true;
      obsidian.enable = true;
      ollama.enable = true;
    };
  };
}
