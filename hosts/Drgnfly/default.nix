{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/sinh

    ../common/optional/pipewire.nix
    ../common/optional/sddm.nix

    ./wifi-networks.nix
  ];

  networking.hostName = "Drgnfly";

  modules = {
    r_setup.enable = true;
    nix_ld.enable = true;
    virtualbox.enable = true;
    fcitx5.enable = true;
    fish.enable = true;

    # windows manager
    bspwm.enable = true;
    hyprland.enable = false;
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "repl-flake"
      ];
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      trusted-users = ["root" "sinh"];
      auto-optimise-store = true;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Enable the X11 windowing system.
  services = {
    ip_updater = {
      enable = true;
      package = pkgs.ip_update;
      wasabiAccessKeyFile = "/home/sinh/.config/sinh-x-local/wasabi-access-key.env";
    };

    xserver = {
      videoDrivers = ["displaylink" "modesetting"];
    };

    picom = {
      enable = true;
      shadow = true;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.libinput.enable = true;

  hardware.acpilight.enable = true;
  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    displaylink
    bitwarden
    bitwarden-cli
  ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [22];
  # networking.firewall.allowedUDPPorts = [ ... ];

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
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
