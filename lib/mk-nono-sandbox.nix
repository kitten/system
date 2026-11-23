{ lib, pkgs, ... }:
{ name, profile }:

assert lib.assertMsg
  (builtins.isString name && builtins.match "[A-Za-z0-9][A-Za-z0-9._-]*" name != null)
  "mk-nono-sandbox: name must be a nonempty package-safe name";
assert lib.assertMsg (builtins.isAttrs profile)
  "mk-nono-sandbox: profile must be an attribute set";

let
  generatedProfile = (pkgs.formats.json { }).generate "${name}-nono-unchecked.json"
    (lib.recursiveUpdate {
      meta = {
        inherit name;
        version = "1.0.0";
      };
    } profile);
  profileFile = pkgs.runCommand "${name}-nono.json" {
    nativeBuildInputs = [ pkgs.buildPackages.nono pkgs.buildPackages.check-jsonschema ];
    NONO_NO_UPDATE_CHECK = "1";
  } ''
    nono profile schema > schema.json
    check-jsonschema --schemafile schema.json ${generatedProfile}
    nono profile validate --strict ${generatedProfile}
    cp ${generatedProfile} "$out"
  '';
in
pkgs.runCommand "${name}-sandbox" {
  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
} ''
  makeBinaryWrapper ${lib.getExe pkgs.nono} "$out" \
    --add-flags "wrap --silent --profile ${profileFile} --"
''
