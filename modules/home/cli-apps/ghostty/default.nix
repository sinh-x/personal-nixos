{
  lib,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.terminal.ghostty;
in
{
  options.${namespace}.cli-apps.terminal.ghostty = {
    enable = mkEnableOption "Ghostty";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        # Colors — Catppuccin Mocha
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        selection-background = "#585b70";
        selection-foreground = "#cdd6f4";
        cursor-color = "#f5e0dc";
        palette = [
          "0=#45475a"
          "8=#585b70"
          "1=#f38ba8"
          "9=#f38ba8"
          "2=#a6e3a1"
          "10=#a6e3a1"
          "3=#f9e2af"
          "11=#f9e2af"
          "4=#89b4fa"
          "12=#89b4fa"
          "5=#f5c2e7"
          "13=#f5c2e7"
          "6=#94e2d5"
          "14=#94e2d5"
          "7=#bac2de"
          "15=#a6adc8"
        ];

        # Fonts
        font-family = "JetBrainsMono Nerd Font";
        font-size = 10;

        # Cursor
        cursor-style = "block";

        # Scrollback
        scrollback-limit = 2000;

        # Mouse
        copy-on-select = "clipboard";
        app-notifications = "no-clipboard-copy";

        # Window layout
        window-padding-x = 12;
        window-padding-y = 12;
        window-decoration = false; # Remove title bar

        # Background
        background-opacity = 0.90;

        # Misc
        confirm-close-surface = false;
        shell-integration = "none";

        # Keybindings
        keybind = "ctrl+shift+x=close_surface";
      };
    };

    xdg.mimeApps = {
      associations.added = {
        "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
      };
      defaultApplications = {
        "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
      };
    };
  };
}
