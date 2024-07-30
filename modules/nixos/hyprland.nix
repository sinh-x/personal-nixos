{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.hyprland;
in {
  options = {
    modules.hyprland.enable = lib.mkEnableOption "bspwm";
  };
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs.unstable.hyprland;
    };
    programs.hyprlock.enable = true;

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
    hardware = {
      opengl.enable = true;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-wlr
    ];

    environment.systemPackages = with pkgs.unstable; [
      pyprland
      gojq
      tofi
      yad
      hyprpicker
      hyprshot
      mako
      waybar
      wofi
      foot
      eww
      libnotify
      swww
      hyprlandPlugins.hycov
      wl-clipboard-rs
      wlroots
    ];
  };
}
