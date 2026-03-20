# FireFly - Portable NixOS daily driver on 128GB USB
# Hardware-generic: boots on any x86_64 PC (no GPU-specific drivers)
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
    fish.enable = true;
    fcitx5.enable = true;
    nix_ld.enable = true;

    # window manager
    wm.niri = {
      enable = true;
      greetd.enable = true;
    };

    # network
    stubby.enable = true;
    wifi.enable = true;
    tailscale = {
      enable = true;
      authKeySecret = "tailscale/Firefly";
      hostname = "firefly";
      operator = "sinh";
      ssh = true;
      resumeFix = true;
    };

    sops.enable = true;

    # Impermanence - btrfs root rollback with persistent storage
    impermanence = {
      enable = true;
      users = [ "sinh" ];
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
    # AMD Ryzen/Radeon support
    amdgpu.initrd.enable = true;
    firmware = [ pkgs.linux-firmware ];

    acpilight.enable = true;
    bluetooth.enable = true;

    trackpoint = {
      enable = true;
      device = "TPPS/2 IBM TrackPoint";
      drift_time = 25;
      sensitivity = 250;
      speed = 120;
    };

    graphics.enable = true;
  };

  environment.systemPackages = with pkgs; [
    parted
    lm_sensors
    nix-tree
    usbutils
    pciutils
  ];

  networking = {
    hostName = "FireFly";
    networkmanager.enable = false;
  };

  services = {
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
