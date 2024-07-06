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

    ../../mouldes/nixos
    
  ];

  networking.hostName = "Elderwood";

  modules = {
    r_setup.enable = true;
    nix_ld.enable = true;
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes repl-flake";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      trusted-users = [ "root" "sinh" ];
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
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
    xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
        greeters.gtk.enable = true;
      };
    sessionCommands = ''
      ${pkgs.bspwm}/bin/bspc wm -r
      source $HOME/.config/bspwm/bspwmrc
    '';
    };
    windowManager.bspwm = {
      enable = true;
      package = pkgs.bspwm;
      sxhkd = {
        package = pkgs.sxhkd;
      };
    };
    };
   displayManager.defaultSession = "none+bspwm";
  };
  
  services.picom = {
    enable = true;
    shadow = true;
  };
  
  # Configure keymap in X11
   services.xserver.xkb.layout = "us";

  hardware.bluetooth.enable = true;

  fileSystems."/home" = {
    device = "/dev/disk/by-label/Home";
    fsType = "ext4";  
  };
  fileSystems."/home/sinh/external-hdd" = {
    device = "/dev/disk/by-label/hdd_1";
    fsType = "ext4";  
  };
  fileSystems."/home/sinh/external-ssd-1" = {
    device = "/dev/disk/by-label/ssd_1";
    fsType = "ext4";  
  };
  fileSystems."/home/sinh/external-ssd-2" = {
    device = "/dev/disk/by-label/ssd_2";
    fsType = "ext4";  
  };

  # TODO: Set your hostname
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 24800 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.ena eble = false;
  networking.wireless = {
    environmentFile = "/home/sinh/.config/wireless.env";
    enable = true;
    userControlled.enable = true;
    networks = {
      "5G_Vuon Nha" = {
        psk = "@vuonnha@";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    noip
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
