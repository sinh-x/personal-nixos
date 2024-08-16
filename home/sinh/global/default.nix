# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      warn-dirty = false;
      access-tokens = lib.mkForce "github.com=${
        builtins.readFile config.sops.secrets."nix/github_access_token".path
      }";
    };
  };

  systemd.user.startServices = "sd-switch";

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

  gtk = {
    iconTheme.name = "tokyonight-gtk-theme_icons-dark";

    theme.package = pkgs.tokyonight-gtk-theme;
    theme.name = "tokyonight-gtk-theme_full";

  };
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs; [
    tokyonight-gtk-theme
    paper-icon-theme
    anydesk

    (libsForQt5.kdenlive.overrideAttrs (prevAttrs: {
      nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ makeBinaryWrapper ];
      postInstall =
        (prevAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/kdenlive --prefix LADSPA_PATH : ${rnnoise-plugin}/lib/ladspa
        '';
    }))
    ffmpeg_7-full
    mpv

    sinh-x-ip_updater

    yt-dlp

    sct # for setting color temperature

    firefox
    tree
    google-chrome
    vscode

    rust_cli_pomodoro
    sinh-x-wallpaper
    sinh-x-gitstatus

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
    zjstatus

    cargo-wasi

    # utility
    p7zip
    alsa-oss
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
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  services.syncthing = {
    enable = true;
    tray = {
      enable = false;
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
