# machines/topper/hardware-configuration.nix
{ modulesPath, lib, ... }:
{
  # Safe baseline; keeps initrd small and pulls in whatever wasn't detected
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Broadly useful drivers so the initrd can see disks on most laptops/VMs
  boot.initrd.availableKernelModules = [
    "xhci_pci"   # USB3 controllers (keyboards, installers)
    "ahci"       # SATA controllers
    "nvme"       # NVMe SSDs
    "sd_mod"     # SCSI disk
    "sr_mod"     # optical (rare, harmless)
    "usbhid"     # USB keyboards in initrd
    "virtio_pci" "virtio_blk" "virtio_scsi"  # common VM disk buses
  ];

  # Load whichever KVM module matches the CPU; mkDefault lets per-host override
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

  # Microcode updates (safe defaults)
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode   = lib.mkDefault true;

  # Good default; hosts can override if they use NetworkManager/systemd-networkd
  networking.useDHCP = lib.mkDefault true;

  # Platform default
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
