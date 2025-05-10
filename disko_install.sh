#!/usr/bin/env bash

sudo nix --extra-experimental-features "nix-command flakes" \
     run 'github:nix-community/disko/latest#disko-install' \
     -- \
     --flake '/tmp/config/etc/nixos#craptop' \
     --mode format \
     --disk main /dev/disk/by-id/ata-LITEON_CV3-8D512-11_SATA_512GB_TW0956WWLOH0091T0083 \
     --write-efi-boot-entries

