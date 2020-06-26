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
  ];

  dank-mono-neue = copyFiles "font-dank-mono-neue" [
    {
      target = "share/fonts/opentype/DankMonoNeue-Regular.otf";
      source = readSecretFile ../assets/DankMonoNeue-Regular.otf;
    }
    {
      target = "share/fonts/opentype/DankMonoNeue-Italic.otf";
      source = readSecretFile ../assets/DankMonoNeue-Italic.otf;
    }
    {
      target = "share/fonts/opentype/DankMonoNeue-Bold.otf";
      source = readSecretFile ../assets/DankMonoNeue-Bold.otf;
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
in

mkMerge [
  {
    fonts.fonts = with pkgs; flatten [
      dank-mono
      dank-mono-neue
      monolisa
      (optional isLinux emojione)
    ];
  }

  (mkIf isDarwin {
    fonts.enableFontDir = true;
  })
]
