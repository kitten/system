{ lib, pkgs, ... }:

with lib; makeOverridable (
  {
    name ? "steamapp-${appId}-${depotId}-${manifestId}",
    appId,
    depotId,
    manifestId,
    hash ? "",
    branch ? null,
    fileList ? null,
    debug ? false,
    passthru ? { },
    meta ? { },
  } @ args:
  let
    fileListArg =
      if isList fileList then
        builtins.toFile "steam-files-list.txt" (concatLines fileList)
      else
        fileList;

    downloadArgs =
      [
        "-app" appId
        "-depot" depotId
        "-manifest" manifestId
      ]
      ++ optionals (branch != null) [ "-beta" branch ]
      ++ optionals (fileList != null) [ "-filelist" fileListArg ]
      ++ optionals debug [ "-debug" ];

    drvArgs = {
      depsBuildBuild = [ pkgs.depotdownloader ];

      strictDeps = true;

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = if hash != "" then hash else fakeHash;

      env.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

      pos = builtins.unsafeGetAttrPos "manifestId" args;

      inherit passthru;
    } // optionalAttrs (args ? meta) { inherit meta; };
  in
  pkgs.runCommand name drvArgs ''
    HOME=$PWD DepotDownloader -dir "$out" ${escapeShellArgs downloadArgs}
    rm -r "$out"/.DepotDownloader
  ''
)
