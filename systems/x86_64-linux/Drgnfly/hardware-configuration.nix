# Hardware configuration for new 2TB SSD with impermanence layout
# Based on Emberroot hardware, but with tmpfs root and persistent partitions
#
# Partition layout (2TB NVMe SSD):
#   nvme0n1p1: 512MB  vfat   /boot/efi  (EFI System Partition)
#   nvme0n1p2: 350GB  ext4   /nix       (Nix store)
#   nvme0n1p3: 1.6TB  ext4   /persist   (Persistent data)
#   nvme0n1p4: 64GB   swap   [swap]     (Swap + hibernation)
#
# NOTE: UUIDs are placeholders - replace after partitioning the new SSD
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ ];
      supportedFilesystems = [
        "ext4"
        "vfat"
      ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    # Root is tmpfs (ephemeral - wiped on reboot)
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=4G"
        "mode=755"
      ];
    };

    # EFI System Partition
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/1B3E-EB7A";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    # Nix store partition (350GB)
    "/nix" = {
      device = "/dev/disk/by-uuid/903631a2-60b7-48e5-b03e-6d07080df4a1";
      fsType = "ext4";
      options = [ "noatime" ];
      neededForBoot = true;
    };

    # Persistent data partition (1.6TB)
    "/persist" = {
      device = "/dev/disk/by-uuid/9e08cb02-a9ed-48c2-a3cb-1eae11c54b20";
      fsType = "ext4";
      options = [ "noatime" ];
      neededForBoot = true;
    };
  };

  # Swap partition (64GB for hibernation)
  swapDevices = [
    { device = "/dev/disk/by-uuid/ac1d28ea-517e-40c4-9240-5f48258f3e57"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
