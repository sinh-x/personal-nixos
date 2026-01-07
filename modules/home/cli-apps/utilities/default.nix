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
      atuin
      awscli2
      bat
      bc
      btop
      dua
      fd
      ffmpegthumbnailer
      fzf
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
      zoxide
    ];

    programs.lsd = {
      enable = true;
    };

    programs.alacritty = {
      enable = true;
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
