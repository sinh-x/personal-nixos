{
  disko.devices = {
    disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              mountOptions = [
                "fmask=0022"
                "dmask=0022"
              ];
            };
          };
          luks = {
            priority = 2;
            size = "100%";
            content = {
              type = "luks";
              name = "lily-crypt";
              settings.allowDiscards = true;
              content = {
                type = "lvm_pv";
                vg = "lily";
              };
            };
          };
        };
      };
    };
    lvm_vg.lily = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "8G";
          content = {
            type = "swap";
            resumeDevice = true;
          };
        };
        root = {
          size = "100%FREE";
          content = {
            type = "btrfs";
            extraArgs = [
              "-f"
              "--label"
              "lily"
            ];
            subvolumes = {
              "@root" = {
                mountpoint = "/";
                mountOptions = [
                  "subvol=@root"
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "subvol=@nix"
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@persist" = {
                mountpoint = "/persist";
                mountOptions = [
                  "subvol=@persist"
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@root-blank" = { };
            };
          };
        };
      };
    };
  };
}
