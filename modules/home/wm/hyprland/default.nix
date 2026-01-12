{
  lib,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.wm.hyprland;
in
{
  options.${namespace}.wm.hyprland = {
    enable = mkEnableOption "Hyprland config using hm";
  };

  config = mkIf cfg.enable {
    home.packages = [ ];

    home.file.".config/hypr" = {
      source = ./hypr_config;
      recursive = true;
    };
  };
}
