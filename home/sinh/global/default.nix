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
  imports =
    [
      # If you want to use home-manager modules from other flakes (such as nix-colors):
      # inputs.nix-colors.homeManagerModule

      # You can also split up your configuration and import pieces of it here:
      # ./nvim.nix
      ../features/fish.nix
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  # TODO: Set your username
  home = {
    username = "sinh";
    homeDirectory = "/home/sinh";
    sessionVariables = {
      IMSETTINGS_MODULE = "fcitx5";
      INPUT_METHOD = "fcitx5";
      GTK_IM_MODULE = "fcitx5";
      QT_IM_MODULE = "fcitx5";
      "GLFW_IM_MODULE" = "ibus";
      XMODIFIERS = "fcitx5";
    };
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs; [
    anydesk

    libsForQt5.kdenlive
    ffmpeg_7-full
    mpv

    ip_update

    yt-dlp

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

    # programming
    clang
    go
    jre_minimal
    julia-lts
    kotlin
    luajit
    mercurial
    nodejs_22
    prettierd
    rstudio

    rustc
    cargo

    tree-sitter
    zig

    # sync
    rclone
    rustic-rs
    ssh-agents

    # shell
    neofetch

    # cli utilities
    atuin
    awscli2
    bat
    btop
    fzf
    git
    gh
    htop
    lazygit
    tldr
    tree
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
    zellij

    cargo-wasi

    # utility
    p7zip
    alsa-oss
    bitwarden
    bluez
    bc
    nh

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

    p7zip
    zip

    zjstatus
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
      size = 11;
    };
    theme = "Gruvbox Material Dark Hard";
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };

  # programs.zellij = {
  #   enable = true;
  #   enableFishIntegration = false;
  #   settings = {
  #     defaultShell = "fish";
  #     scrollback_editor = "nvim";
  #     theme = "Tokyo Night";
  #   };
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
