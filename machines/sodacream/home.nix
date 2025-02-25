{ ... }: {
  modules = {
    development = {
      enable = true;
      js.enable = true;
      zig.enable = true;
      terraform.enable = false;
      react-native.enable = false;
    };
    apps = {
      enable = true;
      firefox.enable = true;
      ghostty.enable = true;
    };
  };
}
