# Hardware configuration for Lily - Lenovo IdeaPad 3 15ADA05
# AMD Ryzen 3 3250U, Radeon Vega 3, 3.2 GiB RAM, 238.5GB NVMe
#
# LUKS + LVM + Btrfs layout:
#   nvme0n1p1  512MB  ESP (unencrypted)
#   nvme0n1p2  rest   LUKS "lily-crypt" -> LVM VG "lily"
#     LV swap  8GB    swap
#     LV root  rest   btrfs (label: lily)
#
# Btrfs subvolumes:
#   @root        -> /          (wiped on every boot via initrd rollback)
#   @nix         -> /nix       (persistent)
#   @persist     -> /persist   (persistent)
#   @root-blank  (empty snapshot, rollback source)
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
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "amdgpu"
      ];
      kernelModules = [ "dm_mod" ];
      supportedFilesystems = [
        "btrfs"
        "vfat"
      ];

      # Rollback @root to empty snapshot on every boot (impermanence)
      postResumeCommands = lib.mkAfter ''
        mkdir -p /mnt
        mount -t btrfs -o subvol=/ /dev/lily/root /mnt

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
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  # fileSystems and swapDevices are managed by disko (see disks.nix)

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
