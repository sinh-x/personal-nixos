{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.utilities;
in
{
  options.${namespace}.cli-apps.utilities = {
    enable = mkEnableOption "CLI Utilities apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2
      bc
      btop
      dnsutils # dig, nslookup, host for DNS queries
      dua
      fd
      ffmpegthumbnailer
      gh
      git
      gitflow
      htop
      jq
      lazygit
      libxml2
      ncdu
      neofetch
      p7zip
      poppler
      ripgrep
      ssh-agents
      tldr
      tree
      unar
      unzip
      xml2
      yazi
      zig
      zip
      zjstatus
    ];

    programs = {
      lsd.enable = true;
      alacritty.enable = true;
      bat = {
        enable = true;
        config = {
          theme = "tokyonight_night";
        };
        themes = {
          tokyonight_night = {
            src = pkgs.fetchFromGitHub {
              owner = "folke";
              repo = "tokyonight.nvim";
              rev = "v4.8.0";
              hash = "sha256-5QeY3EevOQzz5PHDW2CUVJ7N42TRQdh7QOF9PH1YxkU=";
            };
            file = "extras/sublime/tokyonight_night.tmTheme";
          };
        };
      };

      # Shell integrations pre-generated at build time (faster shell startup)
      fzf = {
        enable = true;
        enableFishIntegration = true;
        defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
        defaultOptions = [
          "--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED"
        ];
        fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
        fileWidgetOptions = [
          "--preview 'if [ -d {} ]; then lsd --tree --depth=2 --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
        ];
        changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
        changeDirWidgetOptions = [
          "--preview 'lsd --tree --depth=2 --color=always {} | head -200'"
        ];
      };

      atuin = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        flags = [ "--disable-up-arrow" ]; # Use Ctrl+R instead, keep up-arrow for normal history
        settings = {
          # Sync settings
          auto_sync = true;
          # sync_address = "http://128.199.201.192:9001"; # offline, using default api.atuin.sh
          sync_frequency = "5m";
          sync.records = true;

          # Search/UI settings
          search_mode = "fuzzy";
          filter_mode = "global";
          style = "compact";
          inline_height = 20;
          show_preview = true;
          enter_accept = true;

          # Filter common commands from history
          history_filter = [
            "^ls"
            "^cd"
            "^exit"
          ];
        };
      };

      zoxide = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # Images
        "image/jpeg" = "swayimg.desktop";

        # Browser - zen-twilight
        "x-scheme-handler/http" = "zen-twilight.desktop";
        "x-scheme-handler/https" = "zen-twilight.desktop";
        "x-scheme-handler/chrome" = "zen-twilight.desktop";
        "text/html" = "zen-twilight.desktop";
        "application/xhtml+xml" = "zen-twilight.desktop";
        "application/x-extension-htm" = "zen-twilight.desktop";
        "application/x-extension-html" = "zen-twilight.desktop";
        "application/x-extension-shtml" = "zen-twilight.desktop";
        "application/x-extension-xhtml" = "zen-twilight.desktop";
        "application/x-extension-xht" = "zen-twilight.desktop";

        # Apps
        "x-scheme-handler/viber" = "viber.desktop";
        "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
        "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        "x-scheme-handler/anytype" = "anytype.desktop";

        # PDF
        "application/pdf" = "org.gnome.Evince.desktop";
      };
    };
  };
}
