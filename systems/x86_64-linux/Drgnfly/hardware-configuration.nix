# Hardware configuration for Drgnfly with LUKS + LVM + btrfs + disko + impermanence
# Partition layout managed by disko (see disks.nix)
#
# nvme0n1p2 → LUKS (cryptroot) → LVM VG "drgnfly"
#   LV swap  → swap (64G)
#   LV root  → btrfs (label: nixos)
#     @root        → /          (wiped on every boot via initrd rollback)
#     @nix         → /nix       (persistent)
#     @persist     → /persist   (persistent)
#     @root-blank  (empty snapshot, rollback source)
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
        "uas" # USB Attached SCSI - needed for external NVMe enclosures
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ "dm_mod" ];
      supportedFilesystems = [
        "btrfs"
        "vfat"
      ];

      # Rollback @root to empty snapshot on every boot (impermanence)
      postResumeCommands = lib.mkAfter ''
        mkdir -p /mnt
        mount -t btrfs -o subvol=/ /dev/drgnfly/root /mnt

        if [[ -e /mnt/@root-blank ]]; then
          # Delete old @root and any nested subvolumes
          btrfs subvolume list -o /mnt/@root |
            cut -f9 -d' ' |
            while read subvolume; do
              btrfs subvolume delete "/mnt/$subvolume"
            done
          btrfs subvolume delete /mnt/@root

          # Restore from blank snapshot
          btrfs subvolume snapshot /mnt/@root-blank /mnt/@root
        fi

        umount /mnt
      '';
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  # fileSystems and swapDevices are managed by disko (see disks.nix)

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
