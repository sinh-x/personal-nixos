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
    ../common/optional/sddm.nix
  ];

  sinh-x.default-desktop.enable = true;

  services = {
    ip_updater = {
      enable = true;
      package = pkgs.sinh-x-ip_updater;
      wasabiAccessKeyFile = "/home/sinh/.config/sinh-x-scripts/wasabi-access-key.env";
    };
  };

  virtualisation = {
    docker.enable = true;
  };

  modules = {
    r_setup.enable = true;
    python.enable = true;
    nix_ld.enable = true;
    fcitx5.enable = true;
    fish.enable = true;

    # windows manager
    bspwm.enable = true;
    hyprland.enable = false;

    virtualbox.enable = true;
    genymotion.enable = true;

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
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        trusted-users = [
          "root"
          "sinh"
        ];
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.picom = {
    enable = true;
    shadow = true;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  hardware.bluetooth.enable = true;

  fileSystems = {
    "/home" = {
      device = "/dev/disk/by-label/Home";
      fsType = "ext4";
    };

    "/home/sinh/external-hdd" = {
      device = "/dev/disk/by-label/hdd_1";
      fsType = "ext4";
    };

    "/home/sinh/external-ssd-1" = {
      device = "/dev/disk/by-label/ssd_1";
      fsType = "ext4";
    };

    "/home/sinh/external-ssd-2" = {
      device = "/dev/disk/by-label/ssd_2";
      fsType = "ext4";
    };
  };

  networking = {
    hostName = "Elderwood";
    networkmanager.enable = false;
    firewall.allowedTCPPorts = [
      24800
      22
    ];
    # nameservers = [
    #   "127.0.0.1"
    #   "::1"
    # ];
    # # If using dhcpcd:
    # dhcpcd.extraConfig = "nohook resolv.conf";
    defaultGateway = "192.168.1.1";

    interfaces.wlo1.ipv4.addresses = [
      {
        address = "192.168.1.4";
        prefixLength = 24;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    cups-pdf-to-pdf
    devenv

    # Only 'x86_64-linux' and 'aarch64-linux' are supported
    inputs.zen-browser.packages."${system}".default # beta
    inputs.zen-browser.packages."${system}".beta
    inputs.zen-browser.packages."${system}".twilight # artifacts are downloaded from this repository to guarantee reproducibility
    inputs.zen-browser.packages."${system}".twilight-official # artifacts are downloaded from the official Zen repository
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # opinionated: forbid root login through ssh.
      PermitRootLogin = "no";
      # opinionated: use keys only.
      # remove if you want to ssh using passwords
      PasswordAuthentication = false;
    };
  };

  services.printing = {
    enable = true;
    cups-pdf = {
      enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
