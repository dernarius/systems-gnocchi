#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

git add .
git commit -m "flake update"

# export NIXPKGS_ALLOW_BROKEN=1
run0 nixos-rebuild switch --flake .#gnocchi
