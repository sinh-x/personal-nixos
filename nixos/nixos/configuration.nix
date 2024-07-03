# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

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

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      libsForQt5.fcitx5-unikey
    ];
  };

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
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware.bluetooth.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/Home";
    fsType = "ext4";  
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  
  nix.settings = {
    trusted-users = [ "root" "sinh" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sinh = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" "network" "power" "video" "audio"
      "tty" "dialout"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
      google-chrome
      vscode
      
      # office
      wpsoffice
      obsidian

      activitywatch
      qmk

      tmuxPlugins.tmux-fzf

      # Chat
      caprine-bin
      zoom-us
      viber

      helix
      lazygit

      rstudioWrapper
      # programming
      gh-copilot
      clang
      go
      kotlin

      jre_minimal
      julia-lts

      # luajit
      # luajitpackages.luarocks
      # luajitpackages.tiktoken_core
      # luajitpackages.jsregexp
      # lua54packages.jsregexp
      # lua54packages.tiktoken_core
      #
      mercurial
      nodejs_22
      prettierd

      php
      php83Packages.composer

      python3Full
      python311Packages.pip

      rustc
      rustup
      cargo

      tree-sitter
      zig
      # utility
      copyq
      libsForQt5.fcitx5-unikey
      syncthing
      virtualbox
    ];
  };

  fonts.packages = with pkgs; [
    corefonts
    icomoon-feather
    material-icons
    meslo-lgs-nf
    hackgen-nf-font
    powerline-fonts
    (nerdfonts.override {
      fonts = [
        "FiraCode" "Hack" "Iosevka" "IosevkaTerm"
      ];
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    awscli2
    vim
    wget
    pulsemixer

    tree

    # editor
    lldb
    icu

    lua-language-server
    stylua

    # sync
    rclone
    rustic-rs
    ssh-agents

    # shell
    fish
    neofetch

    # bspwm setup
    alacritty
    bat
    bspwm
    btop
    dunst
    eww
    eza
    feh
    flameshot
    fzf
    git
    gh
    gsettings-qt
    gsimplecal
    htop
    input-leap
    picom
    rofi
    polybar
    xfce.thunar
    tldr
    dmenu
    libnotify
    sxhkd
    killall
    screenkey
    light
    xcolor
    xdg-utils
    xdo
    xclip
    xdotool
    xorg.xev
    xorg.xinit

    # file manager
    dua
    yazi
    fd
    ffmpegthumbnailer
    unar
    jq
    poppler
    ripgrep
    zoxide

    # utility
    gcc
    p7zip
    alsa-oss
    bitwarden
    bluez
    bc

    curl
    libcpr
    ocamlPackages.ocurl

    gnumake
    imagemagick
    xml2
    libxml2
    pkg-config
    openssl
    ocamlPackages.ssl
    acpilight
    unzip

    # R
    R
    (pkgs.rWrapper.override {
    packages = with pkgs.rPackages;
    [
      DT
      RColorBrewer
      RJSONIO
      RgoogleMaps
      Rlof
      V8
      arrow
      assertthat
      bindr
      bindrcpp
      brew
      broom
      covr
      cowplot
      crayon
      curl
      devtools
      doParallel
      doParallel
      feather
      foreach
      formatR
      futile_logger
      ggmap
      ggrepel
      ggvis
      ggpubr
      glue
      golem
      haven
      hms
      htmltools
      htmlwidgets
      httr
      igraph 
      jpeg
      jqr
      jsonlite
      jsonvalidate
      knitr
      languageserver
      languageserversetup
      leaflet
      lgr
      lintr
      lubridate
      maps
      markdown
      modelr
      nlme
      nloptr
      officer
      openxlsx
      rJava
      reactable
      readxl
      readxl
      recipes
      reprex
      reshape2
      rex
      rhandsontable
      rio
      rjson
      rlang
      roxygen2
      rpart
      rvest
      rvg
      scales
      sessioninfo
      sf
      sfsmisc
      shiny
      shinyBS
      shinydashboard
      shinydashboardPlus
      shinythemes
      sjlabelled
      skimr
      slam
      sna
      stringdist
      stringi
      stringr
      testthat
      textcat
      tidyverse
      tidyverse
      tryCatchLog
      usethis
      xml2
      zip
      zoo
    ];})

    # lua
    lua51Packages.lua
    lua51Packages.jsregexp
    lua51Packages.tiktoken_core
    lua51Packages.luarocks-nix

  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      fontconfig
      freetype
      fuse3
      gdk-pixbuf
      glib
      gtk3
      icu
      libGL
      libappindicator-gtk3
      libdrm
      libglvnd
      libnotify
      libpulseaudio
      libunwind
      libusb1
      libuuid
      libxkbcommon
      libxml2
      mesa
      nspr
      nss
      openssl
      pango
      pipewire
      stdenv.cc.cc
      systemd
      vulkan-loader
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxkbfile
      xorg.libxshmfence
      zlib
    
      clang

      kotlin
      
      icu

      lua51Packages.lua
      lua51Packages.jsregexp
      lua51Packages.tiktoken_core
      lua51Packages.luarocks-nix

      python3Full
      python311Packages.pip

      R

      xml2
      libxml2
      lldb

      xclip
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.tmux = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 24800 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.hostName = "sinh-desktop";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      "5G_Vuon Nha" = {
        psk = "minhsinhtruc";
      };
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

