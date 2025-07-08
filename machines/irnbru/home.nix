{ ... }:

{
  modules = {
    development = {
      enable = true;
    };
    apps = {
      enable = true;
      ollama.enable = true;
      ghostty.enable = true;
    };
  };
}
