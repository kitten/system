{ ... }: {
  modules = {
    development.enable = false;
    apps = {
      enable = true;
      firefox.enable = true;
      ghostty.enable = true;
    };
  };
}
