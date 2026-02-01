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
    # ../common/optional/sddm.nix
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

    virtualbox.enable = false;
    genymotion.enable = false;
    docker.enable = true;

    # network
    stubby.enable = true;
    wifi.enable = true;

    sops.enable = true;
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
        ];
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        trusted-users = [
          "root"
          "sinh"
        ];
        auto-optimise-store = true;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
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

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Enable the X11 windowing system.
  services = {
    ip_updater = {
      enable = true;
      package = pkgs.sinh-x-ip_updater;
      wasabiAccessKeyFile = "/home/sinh/.config/sinh-x-scripts/wasabi-access-key.env";
    };

    xserver = {
      videoDrivers = [
        "nvidia"
        "virtualbox"
      ];
    };

    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      settings = {
        glx-no-stencil = true;
        glx-no-rebind-pixmap = true;
      };
    };

    printing = {
      enable = true;
      cups-pdf = {
        enable = true;
      };
      drivers = [ pkgs.brlaser ];
    };

    udev.packages = [ pkgs.qmk-udev-rules ];
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.libinput.enable = true;

  hardware = {
    acpilight.enable = true;
    bluetooth.enable = true;

    # TrackPoint configuration to prevent cursor drift
    trackpoint = {
      enable = true;
      device = "TPPS/2 IBM TrackPoint";
      drift_time = 25; # Default 5, increased to fix spontaneous cursor movement
      sensitivity = 250; # Default 128, range 0-255
      speed = 120; # Default 97, range 0-255
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
      powerManagement.finegrained = true; # Required for s2idle on Turing+ GPUs
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
    libva-vdpau-driver
    libvdpau-va-gl
    nvidia-system-monitor-qt
    nvtopPackages.full

    qmk
    qmk-udev-rules

    linuxPackages.virtualboxGuestAdditions

    # # Only 'x86_64-linux' and 'aarch64-linux' are supported
    # inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    # inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".beta
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight # artifacts are downloaded from this repository to guarantee reproducibility
    # inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight-official # artifacts are downloaded from the official Zen repository
  ];

  # Open ports in the firewall.

  networking = {
    hostName = "Emberroot";
    networkmanager.enable = false;
    firewall.allowedTCPPorts = [ 22 ];
    # If using dhcpcd:
  };
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.steam = {
    enable = true;
  };
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services = {
    flatpak.enable = true;
    upower.enable = true;
    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
