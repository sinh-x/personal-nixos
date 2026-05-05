# Hardware configuration for FireFly - portable NixOS on USB
# Generic x86_64 hardware: boots on Intel or AMD, any GPU (modesetting)
#
# LUKS → LVM → Btrfs layout:
#   /dev/sda1  512MB  ESP (unencrypted)
#   /dev/sda2  8GB    swap (plain)
#   /dev/sda3  rest   LUKS "mobi-crypt" → LVM VG "mobi-vg" → LV "mobi-lv" → BTRFS
#
# Btrfs subvolumes (label: mobi):
#   @root        -> /          (wiped on every boot via initrd rollback)
#   @nix         -> /nix       (persistent)
#   @persist     -> /persist   (persistent)
#   @root-blank  (empty snapshot, rollback source)
{
  config,
  lib,
  modulesPath,
  pkgs,
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
        "amdgpu"
      ];
      kernelModules = [ "dm-mod" ];
      supportedFilesystems = [
        "btrfs"
        "vfat"
      ];

      systemd.services.rollback-root = {
        description = "Rollback Btrfs root subvolume";
        wantedBy = [ "initrd.target" ];
        after = [
          "systemd-cryptsetup@mobi\\x2dcrypt.service"
          "lvm2-activation-early.service"
        ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        path = [
          pkgs.btrfs-progs
          pkgs.coreutils
          pkgs.util-linux
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /mnt
          mount -t btrfs -o subvol=/ /dev/mobi-vg/mobi-lv /mnt

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
    };
    kernelModules = [
      "kvm-intel"
      "kvm-amd"
    ];
    extraModulePackages = [ ];
  };

  # fileSystems and swapDevices are managed by disko (see disks.nix)

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
