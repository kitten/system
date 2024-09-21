{ lib, pkgs, ... }:

with lib;
let
  cfssl = "${pkgs.cfssl}/bin/cfssl";
  cfssljson = "${pkgs.cfssl}/bin/cfssljson";

  caConf = pkgs.writeText "ca-conf.json" (builtins.toJSON {
    signing = {
      profiles = listToAttrs (map ({ name, extra ? [ ] }:
        nameValuePair name {
          usages = extra ++ [ "signing" "key encipherment" "server auth" "client auth" ];
          expiry = "87600h";
        }
      ) [
        { name = "auth-only"; }
        { name = "auth-and-cert-sign"; extra = [ "cert sign" ]; }
      ]);
    };
  });

  mkCSR = name: pkgs.writeText "csr.json" (builtins.toJSON {
    CN = name;
    key = { algo = "rsa"; size = 4096; };
    hosts = [ ];
  });

  mkGenCertCommand = { name, output, settings }: let
    csr = mkCSR name;
    args = attrsets.mapAttrsToList
      (attr: value: if value == true then "-${attr}" else "-${attr}=${toString value}")
      settings;
  in ''
    if [[ ! -f "${output}${name}.crt" ]]; then
      mkdir -p "${output}"
      ${cfssl} gencert ${concatStringsSep " " args} \
        ${csr} | ${cfssljson} -bare "${output}/${name}"
      rm "${output}/${name}.csr"
      mv "${output}/${name}-key.pem" "${output}/${name}.key"
      mv "${output}/${name}.pem" "${output}/${name}.crt"
    fi
  '';

  caCertificate = {
    name = "ca";
    output = "modules/base/certs/";
    settings.initca = true;
  };

  certificates = [
    {
      name = "mqtt";
      output = "modules/automation/certs/";
      settings = {
        profile = "auth-only";
        config = caConf;
        ca = with caCertificate; "${output}/${name}.crt";
        ca-key = with caCertificate; "${output}/${name}.key";
      };
    }
  ];
in
  toString (pkgs.writers.writeBash "genCerts" ''
    set -e
    cd "$DIR"
    ${mkGenCertCommand caCertificate}
    ${concatStringsSep "\n" (map mkGenCertCommand certificates)}
  '')
