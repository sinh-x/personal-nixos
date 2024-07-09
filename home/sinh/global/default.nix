# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  outputs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../features/fish.nix
  ];


  # TODO: Set your username
  home = {
    username = "sinh";
    homeDirectory = "/home/sinh";
    sessionVariables = {
      IMSETTINGS_MODULE="fcitx5";
      INPUT_METHOD="fcitx5";
      GTK_IM_MODULE="fcitx5";
      QT_IM_MODULE="fcitx5";
      "GLFW_IM_MODULE" ="ibus";
      XMODIFIERS="fcitx5";
    };
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs; [

    sct # for setting color temperature

    firefox
    tree
    google-chrome
    vscode

    inputs.home-manager.packages.${pkgs.system}.default

    # office
    wpsoffice
    obsidian

    activitywatch
    qmk

    # # Chat
    caprine-bin
    zoom-us
    viber
    slack

    helix
    lazygit

    rstudio
    # programming
    clang
    go
    kotlin

    jre_minimal
    julia-lts

    luajit
    #
    mercurial
    nodejs_22
    prettierd

    rustc
    cargo

    tree-sitter
    zig

    # # utility
    copyq

    nh

    awscli2

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
    neofetch

    # bspwm setup
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
    # picom
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
    p7zip
    alsa-oss
    bitwarden
    bluez
    bc

    libcpr
    ocamlPackages.ocurl

    gnumake
    imagemagick
    xml2
    libxml2
    pkg-config
    ocamlPackages.ssl
    acpilight
    unzip
    fish
    neovim

    pulsemixer
    tmux

    p7zip
    zip
  ];

  fonts.fontconfig = {
    enable = true;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthing-tray";
      package = pkgs.syncthing-tray;
    };
  };

  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
  };

  programs.ncmpcpp = {
    enable = true;
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.alacritty = {
    enable = true;
  };


  programs.kitty = {
    enable = true;
    font = {
      name = "IosevkaTerm Nerd Font"; 
      size = 10;
    };
    theme = "Gruvbox Material Dark Hard";
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
  };


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
