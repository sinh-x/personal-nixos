{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.impermanence;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.impermanence = {
    enable = mkEnableOption "Enable impermanence for stateless system";
  };

  config = mkIf cfg.enable {
    # Import impermanence module
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    # Boot configuration for btrfs rollback
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/disk/by-label/nixos /btrfs_tmp
      if [[ -e /btrfs_tmp/@ ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y%m%d-%H%M%S")
          mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/@
      umount /btrfs_tmp
    '';

    # Define what to persist
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/etc/ssh"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };

    # Persist system state directories
    systemd.tmpfiles.rules = [
      "L /var/lib/NetworkManager - - - - /persist/var/lib/NetworkManager"
    ];

    # Additional system persistence for common services
    programs.fuse.userAllowOther = true;
  };
}
