{ lib, pkgs }:

rec {
  secretName = name: index: "${name}-${toString index}.env";

  environmentFileOptions = defaultPath: {
    enable = lib.mkEnableOption "agenix-managed environment credentials";
    path = lib.mkOption {
      default = defaultPath;
      description = "Encrypted agenix env file or ordered list of files; later files override earlier values.";
      type = lib.types.either lib.types.path (lib.types.nonEmptyListOf lib.types.path);
      apply = lib.toList;
    };
  };

  runtimeFiles = name: environmentFile: secrets:
    if environmentFile.enable then lib.imap0 (index: _:
      secrets.${secretName name index}.path
    ) environmentFile.path else [ ];

  wrapperArgs = environmentFiles: lib.concatMap (file: [
    "--run" "set -a; . ${lib.escapeShellArg file} || exit $?; set +a"
  ]) environmentFiles;

  wrap = package: environmentFiles: binaries:
    if environmentFiles == [ ] then package else pkgs.symlinkJoin {
      name = "${package.name}-with-env";
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = lib.concatMapStringsSep "\n" (binary: ''
        wrapProgram "$out/bin/${binary}" ${lib.escapeShellArgs (wrapperArgs environmentFiles)}
      '') binaries;
      meta = package.meta or { };
    } // lib.optionalAttrs (package ? version) { inherit (package) version; };
}
