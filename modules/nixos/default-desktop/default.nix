{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set. # The system architecture for this host (eg. `x86_64-linux`). # The Snowfall Lib target for this system (eg. `x86_64-iso`). # A normalized name for the system target (eg. `iso`). # A boolean to determine whether this system is a virtual target using nixos-generators. # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.default-desktop;
in
{
  options.${namespace}.default-desktop = {
    enable = mkEnableOption "Enable default desktop.";
  };

  config = mkIf cfg.enable {

    home-manager.useGlobalPkgs = true;
    home-manager.extraSpecialArgs = {
      inherit inputs;
    };

    # Increase open file limit for sudoers
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

    networking.nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];

    # Set your time zone.
    time.timeZone = "Asia/Ho_Chi_Minh";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   usxeXkbConfig = true; # use xkb.options in tty.
    # };

    fonts.packages = with pkgs; [
      corefonts
      lato
      icomoon-feather
      material-icons
      meslo-lgs-nf
      hackgen-nf-font
      powerline-fonts
      ubuntu_font_family
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Hack"
          "Iosevka"
          "IosevkaTerm"
          "JetBrainsMono"
        ];
      })
      dancing-script
      sinh-x.wps-missing-fonts
      sinh-x.archcraft-icons-fonts
    ];

    # list packages installed in system profile. to search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim
      wget
      curl
      openssl
      ocamlPackages.ssl

      sinh-x.sys
    ];

    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
