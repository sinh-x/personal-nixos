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
    ../features/tmux.nix
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
    virtualbox

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
    openssl
    ocamlPackages.ssl
    acpilight
    unzip
    fish
    neovim

    pulsemixer
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

  programs.fish = {
    enable = true;
    shellInitLast = ''
      # Commands to run in interactive sessions can go here
      # ----- general alias -----
      # alias tmux "tmux -f ~/.config/tmux/tmux.conf"
      alias vim nvim
      alias ssha ssh-add
      alias sshconfig "nvim ~/.ssh/config"
      alias cat bat

      # ----- ls abbr -----
      abbr lsg "ls | grep"
      abbr llg "ls -l | grep"
      abbr lag "ls -la | grep"

      # ----- git abbr -----
      abbr g git
      abbr gs "git status"
      abbr ga "git add"
      abbr gc "git commit"
      abbr gcm "git commit -m"
      abbr gp "git push"
      abbr gpl "git pull"
      abbr gco "git checkout"
      abbr gb "git branch"
      abbr gba "git branch -a"
      abbr gbd "git branch -d"
      abbr gbm "git branch -m"
      abbr gl "git log"
      abbr gll "git log --oneline"
      abbr gd "git diff"
      abbr gds "git diff --staged"
      abbr gdc "git diff --cached"
      abbr gcl "git clone"
      abbr gcf "git config --list"
      abbr gsw "git switch"
      abbr lg lazygit

      alias sshref="rm ~/.ssh/known_hosts"

      # ----- FZF -----
      fzf --fish | source

      # --- setup fzf theme ---
      set fg "#CBE0F0"
      set bg "#011628"
      set bg_highlight "#143652"
      set purple "#B388FF"
      set blue "#06BCE4"
      set cyan "#2CF9ED"

      set -x FZF_DEFAULT_OPTS "--color=fg:$fg,bg:$bg,hl:$purple,fg+:$fg,bg+:$bg_highlight,hl+:$purple,info:$blue,prompt:$cyan,pointer:$cyan,marker:$cyan,spinner:$cyan,header:$cyan"

      # -- Use fd instead of fzf --
      set -x FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
      set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
      set -x FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

      set show_file_or_dir_preview "if [ -d {} ]; eza --tree --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end"

      set -x FZF_CTRL_T_OPTS "--preview '$show_file_or_dir_preview'"
      set -x FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

      # ----- Bat (better cat) -----
      set -x BAT_THEME tokyonight_night

      # ---- Eza (better ls) -----
      alias ls "eza --icons=always"

      # ----- Zoxide (better cd) ------
      zoxide init fish | source
      alias cd z

      # ----- tmux.fish  ------
      set -Ux fish_tmux_autostart_once true
      set -Ux fish_tmux_autostart false
      set -Ux fish_tmux_autostarted false
      set -Ux fish_tmux_autoconnect true
      set -Ux fish_tmux_autoquit false
      set -Ux fish_tmux_config /home/sinh/.config/tmux.conf

      # ----- Tmux session wizard -----
      fish_add_path $HOME/.config/tmux/plugins/tmux-session-wizard/bin

      # ----- sinh-x plugin -----
      set sinh_git_folders (/usr/bin/env cat ~/.config/sinh-x-local/sinh_git_folders.txt | read -z)
    '';
    plugins = [
      {
        name = "sinh-x.fish";
        src = pkgs.fetchFromGitHub {
          owner = "sinh-x";
          repo = "sinh-x.fish";
          rev = "c5c129444aa1308ea64b8174fe83b53e8e9fe9f8";
          sha256 = "IYWufjnAPWCd/A5o4zCt4fxVHIAqrdeY+4Y/cCK6Ioc=";
        };
      }
      {  name = "ggl";  
         src = pkgs.fetchFromGitHub {
           owner = "sinh-x";
           repo = "ggl.fish";
           rev = "c7bbaa33a68ed2033a543598f22dd9b9443805d6";
           sha256 = "YnkX18J/1KDW5C0JpWIDmAQD3dfxJ68OmVttgI0v0iE=";  
         };
      }
      {
        name = "tmux";
        src = pkgs.fetchFromGitHub {
          owner = "budimanjojo";
          repo = "tmux.fish";
          rev = "e95dbc11fa57d738cd837cb659d50b73ec0a8d90";
          sha256 = "tNq/F9NQZZ1pd0ZWPzQVwuHABCVECmXRN12ovGSUUFU=";
        };
      }
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
