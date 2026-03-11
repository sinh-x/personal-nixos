# Lily - Lenovo IdeaPad 3 15ADA05
# AMD Ryzen 3 3250U, Radeon Vega 3, 3.2 GiB RAM, 238.5GB NVMe
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware-configuration.nix
    ../common/optional/pipewire.nix
  ];

  sinh-x.default-desktop.enable = true;

  modules = {
    r_setup.enable = false;
    python.enable = true;
    nix_ld.enable = true;
    fcitx5.enable = true;
    fish.enable = true;
    gcloud.enable = false;
    antigravity.enable = false;
    gurk.enable = false;

    # window manager
    wm = {
      bspwm.enable = false;
      hyprland.enable = false;
      niri = {
        enable = true;
        greetd = {
          enable = true;
          autoLogin = {
            enable = true;
            user = "doangia";
          };
        };
      };
    };

    docker.enable = false;

    # network
    stubby.enable = true;
    wifi = {
      enable = true;
      interfaces = [ "wlp2s0" ];
    };

    sops.enable = true;

    tailscale = {
      enable = true;
      authKeySecret = "tailscale/Lily";
      operator = "sinh";
      ssh = true;
      resumeFix = true;
    };

    users.doangia.enable = true;

    # Impermanence - btrfs root rollback with persistent storage
    impermanence = {
      enable = true;
      users = [
        "sinh"
        "doangia"
      ];
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
        ];
        flake-registry = "";
        nix-path = config.nix.nixPath;
        trusted-users = [
          "root"
          "sinh"
        ];
        auto-optimise-store = true;
      };
      channel.enable = false;
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      gc = {
        automatic = false;
        dates = "weekly";
        options = "--delete-older-than 28d";
      };
    };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
    extraModprobeConfig = ''
      options snd-hda-intel
    '';
  };

  # Unblock WiFi RF-kill on boot (some laptops default to soft-blocked)
  systemd.services.rfkill-unblock-wifi = {
    description = "Unblock WiFi RF-kill";
    after = [ "systemd-rfkill.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock wifi";
    };
  };

  services = {
    # Monthly btrfs scrub to detect data corruption
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };

    xserver.videoDrivers = [
      "amdgpu"
      "modesetting"
    ];

    udev.packages = [ ];
  };

  services.xserver.xkb.layout = "us";
  services.libinput.enable = true;

  hardware = {
    # AMD Ryzen/Radeon Vega 3 support
    amdgpu.initrd.enable = true;
    firmware = [ pkgs.linux-firmware ];

    acpilight.enable = true;
    bluetooth.enable = true;

    graphics.enable = true;
  };

  environment.systemPackages = with pkgs; [
    parted
    gptfdisk
    lm_sensors
    nix-tree
    yq
    ntfs3g
    compsize

    usbutils
    smartmontools
    pciutils
    libva
    libva-utils

    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
  ];

  networking = {
    hostName = "Lily";
    networkmanager.enable = false;
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };

  services = {
    flatpak.enable = true;
    upower.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  system.stateVersion = "24.11";
}
