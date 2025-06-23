{ ... }: {
  modules = {
    desktop.enable = true;
    development = {
      enable = true;
      js.enable = true;
      zig.enable = true;
      terraform.enable = false;
      react-native.enable = false;
    };
    apps = {
      enable = true;
      ollama.enable = true;
      ghostty.enable = true;
      zen-browser.enable = true;
      discord.enable = true;
      chromium.enable = true;
      zed-editor.enable = true;
    };
  };
}
