#!/usr/bin/env bash
set -eu -o pipefail
rm -f ./node-env.nix
npx node2nix -i node-packages.json -o node-packages.nix -c composition.nix
