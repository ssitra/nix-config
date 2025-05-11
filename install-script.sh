#!/usr/bin/env bash

set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TARGET_HOST="${1:-}"
TARGET_USER="${2:-ratso}"

echo $TARGET_HOST
echo $TARGET_USER

echo "host/${TARGET_HOST}/disks.nix"

sudo true

sudo nix run github:nix-community/disko \
     --extra-experimental-features "nix-command flakes" \
     --no-write-lock-file \
     -- \
     --mode zap_create_mount \
     "machines/${TARGET_HOST}/disks.nix"

sudo nixos-generate-config --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix /tmp/nix-config/machines/topper/hardware-configuration.nix
sudo chown nixos:users /tmp/nix-config/machines/topper/hardware-configuration.nix


sudo nixos-install --flake ".#${TARGET_HOST}"

