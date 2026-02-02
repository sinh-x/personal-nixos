{
  lib,
  pkgs,
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
    home.packages = [
      pkgs.ghostty
    ];

    xdg.mimeApps = {
      associations.added = {
        "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
      };
      defaultApplications = {
        "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
      };
    };

    xdg.configFile."ghostty/config".text = ''
      font-family = IosevkaTerm Nerd Font
      font-size = 12

      background-opacity = 0.90
      confirm-close-surface = false

      window-padding-x = 2
      window-padding-y = 2

      scrollback-limit = 100000
    '';
  };
}
