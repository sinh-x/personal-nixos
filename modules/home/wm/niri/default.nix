{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.wm.niri;
in
{
  options.${namespace}.wm.niri = {
    enable = mkEnableOption "Niri config using hm";

    monitors = {
      primary = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Primary monitor name (e.g., eDP-1). Auto-detected if null.";
        example = "eDP-1";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        jq
        socat
      ];

      file = {
        ".config/niri/config.kdl".source = ./niri_config/config.kdl;
        ".config/niri/scripts" = {
          source = ./niri_config/scripts;
          recursive = true;
        };
        ".config/mako" = {
          source = ./niri_config/mako;
          recursive = true;
        };
        ".config/niri/rofi" = {
          source = ./niri_config/rofi;
          recursive = true;
        };
        ".config/niri/theme" = {
          source = ./niri_config/theme;
          recursive = true;
        };
        ".config/niri/wallpapers" = {
          source = ./niri_config/wallpapers;
          recursive = true;
        };
        ".config/waybar" = {
          source = ./niri_config/waybar;
          recursive = true;
        };
      };
    };
  };
}
