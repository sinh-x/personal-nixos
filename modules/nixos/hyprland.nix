{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.hyprland;
in {
  options = {
    modules.hyprland.enable = lib.mkEnableOption "hyprland";
  };
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs.hyprland;
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

    environment.systemPackages = [
      pkgs.pyprland
      pkgs.gojq
      pkgs.tofi
      pkgs.yad
      pkgs.hyprpicker
      pkgs.hyprshot
      pkgs.mako
      pkgs.waybar
      pkgs.wofi
      pkgs.wofi-pass
      pkgs.foot
      pkgs.eww
      pkgs.libnotify
      pkgs.swww
      pkgs.wl-clipboard-rs
      pkgs.wlroots
      pkgs.wlr-randr

      pkgs.qt5.qtwayland

      inputs.hyprhook.packages.x86_64-linux.hyprhook
      pkgs.hyprlandPlugins.hycov
    ];
  };
}
