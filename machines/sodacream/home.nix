{ ... }: {
  modules = {
    development.enable = false;
    desktop.enable = true;
    apps = {
      enable = true;
      firefox.enable = true;
      ghostty.enable = true;
    };
  };
}
