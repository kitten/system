{ config, lib, user, ... }:

with lib;
{
  system.activationScripts.preActivation.text = mkAfter ''
    for id in ${concatStringsSep " " config.age.identityPaths}; do
      if [ -f "$id" ]; then
        chown ${user} "$id"
        chmod 0400 "$id"
      fi
    done
  '';
}
