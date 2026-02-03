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
        ".config/niri" = {
          source = ./niri_config;
          recursive = true;
        };
      };
    };
  };
}
