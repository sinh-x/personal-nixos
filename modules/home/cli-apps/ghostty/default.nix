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
        # Include hypr config for colors and fonts
        config-file = "~/.config/hypr/ghostty/config";
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
