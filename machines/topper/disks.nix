# /tmp/single-luks-btrfs.nix
# Usage (DESTROYS the target disk!):
  # sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  #   --mode destroy,format,mount \
  #   --argstr disk /dev/disk/by-id/PUT-YOUR-DISK-ID-HERE \
  #   /tmp/single-luks-btrfs.nix
# /tmp/single-luks-btrfs.nix
{ lib ? import <nixpkgs/lib> {}
, disk ? "/dev/vda"
, useKeyFile ? false
, keyFile ? "/tmp/secret.key"
, extraKeyFiles ? [ ]
, swapSize ? "8G"   # set to "0" to skip swapfile creation
, ...
}:

let
  luksSettings =
    { allowDiscards = true; } //
    (lib.optionalAttrs useKeyFile { keyFile = keyFile; });

  swapSubvol =
    lib.optionalAttrs (swapSize != "0") {
      "/swap" = {
        mountpoint = "/.swapvol";
        swap.swapfile.size = swapSize;
      };
    };
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings = luksSettings;
              additionalKeyFiles = extraKeyFiles;

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes =
                  {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" "ssd" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  }
                  // swapSubvol;
              };
            };
          };
        };
      };
    };
  };
}
