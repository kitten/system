{ lib, pkgs, ... }:

with lib;
{
  mkSymlinks = name: symlinks:
    pkgs.writeShellScript "${name}-symlinks"
    (concatStringsSep "\n"
      (mapAttrsToList
        (n: v: ''
          if [[ -L "${n}" ]]; then
            unlink "${n}"
          elif [[ -e "${n}" ]]; then
            echo "${n} already exists, moving"
            mv "${n}" "${n}.bak"
          fi
          mkdir -p "$(dirname "${n}")"
          ln -sf "${v}" "${n}"
        '')
        symlinks));

  mkFiles = name: files:
    pkgs.writeShellScript "${name}-files"
    (concatStringsSep "\n"
      (mapAttrsToList
        (n: v: ''
          if [[ -L "${n}" ]]; then
            unlink "${n}"
          elif ${pkgs.diffutils}/bin/cmp -s "${n}" "${v}"; then
            rm "${n}"
          elif [[ -e "${n}" ]]; then
            echo "${n} already exists, moving"
            mv "${n}" "${n}.bak"
          fi
          mkdir -p $(dirname "${n}")
          ${pkgs.gawk}/bin/awk '{
            for(varname in ENVIRON)
              gsub("@"varname"@", ENVIRON[varname])
            print
          }' "${v}" > "${n}"
          chmod --reference="${v}" "${n}"
        '')
        files));

  mkDirs = name: dirs:
    pkgs.writeShellScript "${name}-dirs"
    (concatStringsSep "\n"
      (mapAttrsToList
        (n: v: ''
          if [[ -L "${n}" ]]; then
            unlink "${n}"
          elif [[ ! -d "${n}" ]]; then
            echo "${n} already exists and isn't a directory, moving"
            mv "${n}" "${n}.bak"
          fi
          ${pkgs.rsync}/bin/rsync -avu "${v}/" "${n}"
          chmod -R u+w "${n}"
        '')
        dirs));

  rmSymlinks = name: symlinks:
    pkgs.writeShellScript "${name}-rm-symlinks"
    (
      concatStringsSep "\n"
      (mapAttrsToList (n: _v: "unlink \"${n}\"") symlinks)
    );

  rmFiles = name: files:
    pkgs.writeShellScript "${name}-rm-symlinks"
    (
      concatStringsSep "\n"
      (mapAttrsToList (n: _v: "rm \"${n}\"") files)
    );
}
