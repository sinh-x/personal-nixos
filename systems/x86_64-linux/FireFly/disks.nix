{
  disko.devices = {
    disk.sdb = {
      type = "disk";
      device = "/dev/sdb";
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
          root = {
            priority = 2;
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "--label"
                "mobi"
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
          swap = {
            priority = 3;
            size = "8G";
            content = {
              type = "swap";
              resumeDevice = false;
            };
          };
        };
      };
    };
  };
}
