{ ... }:

{
  modules = {
    development = {
      enable = true;
      react-native.enable = false;
    };
    apps = {
      enable = true;
      ghostty.enable = true;
    };
  };
}
