{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.hyprland;
in {
  options = {
    modules.hyprland.enable = lib.mkEnableOption "bspwm";
  };
  config = lib.mkIf cfg.enable {
    programs.tofi = {
      enable = true;
      settings = {
        font = "FiraCode Nerd Font Mono";
      };
    };
  };
}
