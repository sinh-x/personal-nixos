# FireFly - Portable NixOS daily driver on 128GB USB
# Based on Drgnfly config, lighter for USB use (no Docker, VMs, heavy dev tools)
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
        greetd.enable = true;
        greetd.autoLogin.enable = false;
      };
    };

    docker.enable = false;

    # network
    stubby.enable = true;
    wifi.enable = true;

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
    kernelParams = [
      "usb-storage.quirks=21c4:b083:u" # Lexar E300 SSD enclosure - disable UAS (buggy firmware)
    ];
    extraModprobeConfig = ''
      options snd-hda-intel
    '';
    blacklistedKernelModules = [ "nouveau" ];
  };

  services = {
    # Monthly btrfs scrub to detect data corruption
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };

    xserver.videoDrivers = [ "nvidia" ];

    udev.packages = [ ];
  };

  services.xserver.xkb.layout = "us";
  services.libinput.enable = true;

  hardware = {
    acpilight.enable = true;
    bluetooth.enable = true;

    trackpoint = {
      enable = true;
      device = "TPPS/2 IBM TrackPoint";
      drift_time = 25;
      sensitivity = 250;
      speed = 120;
    };

    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;

      prime = {
        sync.enable = false;
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      package = config.boot.kernelPackages.nvidiaPackages.stable;

      powerManagement.enable = true;
      powerManagement.finegrained = false;
      forceFullCompositionPipeline = false;
    };

    graphics = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    parted
    gptfdisk
    lm_sensors
    nix-tree
    yq
    ntfs3g
    compsize
    sinh-x.firefly-restore

    pciutils
    libva
    libva-utils
    nvidia-vaapi-driver
    libvdpau-va-gl
    nvtopPackages.full

    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
  ];

  networking = {
    hostName = "FireFly";
    networkmanager.enable = false;
    firewall = {
      allowedTCPPorts = [ 22 ];
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

  services.tailscale.enable = true;

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
