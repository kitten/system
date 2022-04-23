{ pkgs, lib, ... }:

let
  inherit (import ../nix/secrets.nix) readSecretFile;
  inherit (import ../nix/derivations.nix) copyFiles;

  inherit (lib) mkMerge mkIf optional flatten;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;

  dank-mono = copyFiles "font-dank-mono" [
    {
      target = "share/fonts/opentype/DankMono-Regular.otf";
      source = readSecretFile ../assets/DankMono-Regular.otf;
    }
    {
      target = "share/fonts/opentype/DankMono-Italic.otf";
      source = readSecretFile ../assets/DankMono-Italic.otf;
    }
    {
      target = "share/fonts/opentype/DankMono-Bold.otf";
      source = readSecretFile ../assets/DankMono-Bold.otf;
    }
  ];

  monolisa = copyFiles "font-monolisa" [
    {
      target = "share/fonts/opentype/MonoLisa-Regular.otf";
      source = readSecretFile ../assets/MonoLisa-Regular.otf;
    }
    {
      target = "share/fonts/opentype/MonoLisa-Bold.otf";
      source = readSecretFile ../assets/MonoLisa-Bold.otf;
    }
    {
      target = "share/fonts/opentype/MonoLisa-BoldItalic.otf";
      source = readSecretFile ../assets/MonoLisa-BoldItalic.otf;
    }
  ];

  codicons = copyFiles "font-codicon" [
    {
      target = "share/fonts/opentype/codicon.ttf";
      source = readSecretFile ../assets/codicon.ttf;
    }
  ];
in

mkMerge [
  {
    fonts.fonts = with pkgs; flatten [
      monolisa
      dank-mono
      codicons
      (optional isLinux emojione)
    ];
  }

  (mkIf isDarwin {
    fonts.fontDir.enable = true;
  })
]
