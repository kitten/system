{ lib, pkgs, ... } @ inputs:

with lib;
let
  fetchSteam = (import ./fetchSteam.nix) inputs;
  inherit ((import ./steamworks.nix) inputs) steamworks-sdk-redist;
in
{
  name,
  hash ? "",
  version,
  appId,
  depotId,
  manifestId,
  ...
} @ args: let
  mkDerivationArgs = builtins.removeAttrs args [ "name" "appId" "depotId" "manifestId" "hash" ];
in pkgs.stdenv.mkDerivation (rec {
    pname = name;
    src = fetchSteam {
      inherit name appId depotId manifestId hash;
    };
    dontBuild = true;
    dontConfigure = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall

      mkdir -p $out
      mv ./* $out
      chmod 755 -R $out

      runHook postInstall
    '';
  } // mkDerivationArgs)
