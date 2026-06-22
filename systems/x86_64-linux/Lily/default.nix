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

  sinh-x.default-desktop.enable = false;

  # Essentials previously from sinh-x.default-desktop
  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";

  fonts.packages = with pkgs; [
    corefonts
    lato
    icomoon-feather
    material-icons
    meslo-lgs-nf
    hackgen-nf-font
    powerline-fonts
    ubuntu-classic
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.jetbrains-mono
    dancing-script
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  modules = {
    fcitx5.enable = true;
    fish.enable = true;

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

    docker.enable = true;
    thermal-printer.enable = true;

    rustic-backup = {
      enable = true;
      profile = "baker-prod";
      dataDir = "/home/sinh/bakery-shop/prod/data";
      calendar = "hourly";
      user = "sinh";
    };

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
      hostname = "lily";
      operator = "sinh";
      ssh = true;
      resumeFix = true;
    };

    users = {
      doangia.enable = true;
      vy.enable = true;
      sinh.enable = true;
    };

    # Impermanence - btrfs root rollback with persistent storage
    impermanence = {
      enable = true;
      users = [
        "doangia"
        "vy"
        "sinh"
      ];
    };
  };

  # doangia is the primary user on Lily — grant sudo + docker
  users.users.doangia.extraGroups = [
    "wheel"
    "docker"
  ];
  users.users.vy.extraGroups = [ "docker" ];

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
    vim
    git
    wget
    curl
    openssl

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

    rclone
    rustic
    docker-client
  ];

  networking = {
    hostName = "Lily";
    networkmanager.enable = false;
    firewall = {
      allowedTCPPorts = [
        22
        631
      ];
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

    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
      listenAddresses = [ "*:631" ];
      defaultShared = true;
      browsing = false;
      allowFrom = [ "100.64.0.0/10" ];
      extraConf = ''
        ServerName lily.tail10c2c6.ts.net
        <Location /printers>
          Order allow,deny
          Allow from all
        </Location>
      '';
    };
  };

  # CUPS NixOS module blacklists usblp (it prefers libusb). But our Y41BT
  # config uses parallel:/dev/usb/lp0 which needs usblp. Remove the blacklist.
  boot.blacklistedKernelModules = [ ];

  # Configure Y41BT raw queue after CUPS starts — also mark as shared for remote access
  systemd.services.cups-y41bt-setup = {
    description = "Configure Y41BT thermal printer raw queue in CUPS";
    wantedBy = [ "multi-user.target" ];
    after = [ "cups.service" ];
    requires = [ "cups.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.cups ];
    script = ''
      if ! lpstat -p Y41BT > /dev/null 2>&1; then
        lpadmin -p Y41BT -E -v parallel:/dev/usb/lp0 -m raw \
          -L "Lily" -D "Y41BT Thermal Receipt Printer"
      fi
      # Ensure printer is shared so remote CUPS clients can see and use it
      lpadmin -p Y41BT -o printer-is-shared=true
    '';
  };

  system.stateVersion = "24.11";
}
