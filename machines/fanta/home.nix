{ ... }:

{
  modules = {
    development = {
      enable = true;
    };
    apps = {
      enable = true;
      ghostty.enable = true;
    };
  };
}
