# Drgnfly - Emberroot clone with impermanence for new 2TB SSD
# This config will be installed on the new SSD, then swapped into Emberroot hardware
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
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
    gcloud.enable = true;
    antigravity.enable = true;
    gurk.enable = false;

    # windows manager
    wm = {
      bspwm.enable = false;
      hyprland = {
        enable = true;
        greetd = {
          enable = true;
          autoLogin = {
            enable = true;
            user = "sinh";
          };
        };
      };
    };

    docker.enable = true;

    # network
    stubby.enable = true;
    wifi.enable = true;

    sops.enable = true;

    # Impermanence - tmpfs root with persistent storage
    impermanence = {
      enable = true;
      users = [ "sinh" ]; # Persist entire home directory
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
    # Note: deep sleep (S3) not supported on this hardware, only s2idle available
    kernelParams = [ ];
    extraModprobeConfig = ''
      options snd-hda-intel
    '';
    blacklistedKernelModules = [ "nouveau" ];
  };

  services = {
    ip_updater = {
      enable = true;
      package = pkgs.sinh-x-ip_updater;
      wasabiAccessKeyFile = "/home/sinh/.config/sinh-x-scripts/wasabi-access-key.env";
    };

    xserver = {
      videoDrivers = [ "nvidia" ];
    };

    printing = {
      enable = true;
      cups-pdf.enable = true;
      drivers = [ pkgs.brlaser ];
    };

    udev.packages = [ pkgs.qmk-udev-rules ];
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
      # Use the proprietary driver
      modesetting.enable = true;

      # Enable the NVIDIA settings menu
      nvidiaSettings = true;
      open = false;

      # Enable the PRIME offloading (if you have a laptop with hybrid graphics)
      prime = {
        sync.enable = false;
        offload.enable = true;
        offload.enableOffloadCmd = true; # Provides `nvidia-offload` command
        # Intel is usually the integrated GPU
        intelBusId = "PCI:0:2:0";
        # The NVIDIA GPU
        nvidiaBusId = "PCI:1:0:0";
      };

      # Optionally, enable Vulkan support if needed
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      powerManagement.enable = true;
      powerManagement.finegrained = false; # Disabled - was causing suspend hangs (nvkms_unregister_backlight blocking)
      forceFullCompositionPipeline = false; # Can cause suspend issues
    };

    # Optional: Enable OpenGL
    graphics = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    parted
    gptfdisk
    lm_sensors
    direnv
    devenv
    nix-tree
    yq
    ntfs3g
    cargo-binstall # Install pre-built Rust binaries from GitHub (e.g., cargo binstall gurk-rs)

    pciutils
    libva
    libva-utils # VA-API diagnostics (vainfo)
    nvidia-vaapi-driver # Native VA-API support for NVIDIA
    libvdpau-va-gl
    nvidia-system-monitor-qt
    nvtopPackages.full

    qmk
    qmk-udev-rules

    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
  ];

  networking = {
    hostName = "Drgnfly";
    networkmanager.enable = false;
    firewall.allowedTCPPorts = [ 22 ];
  };

  programs.steam.enable = true;

  # QEMU/KVM virtualization for VM testing
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Add libvirtd group for this system
  users.users.sinh.extraGroups = [ "libvirtd" ];

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
