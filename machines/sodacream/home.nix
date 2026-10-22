{ ... }:

{
  modules = {
    development = {
      enable = true;
      t3code.enable = true;
    };
    apps = {
      enable = true;
      ghostty.enable = true;
    };
  };
}
