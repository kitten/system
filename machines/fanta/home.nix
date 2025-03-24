{ ... }:

{
  modules = {
    development.enable = true;
    apps = {
      enable = true;
      firefox.enable = true;
      obsidian.enable = true;
      ollama.enable = true;
      ghostty.enable = true;
      slack.enable = true;
    };
  };
}
