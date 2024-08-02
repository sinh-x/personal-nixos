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

    environment.systemPackages = [
      pkgs.unstable.pyprland
      pkgs.unstable.gojq
      pkgs.unstable.tofi
      pkgs.unstable.yad
      pkgs.unstable.hyprpicker
      pkgs.unstable.hyprshot
      pkgs.unstable.mako
      pkgs.unstable.waybar
      pkgs.unstable.wofi
      pkgs.unstable.wofi-pass
      pkgs.unstable.foot
      pkgs.unstable.eww
      pkgs.unstable.libnotify
      pkgs.unstable.swww
      pkgs.unstable.wl-clipboard-rs
      pkgs.unstable.wlroots
      pkgs.unstable.wlr-randr

      pkgs.qt5.qtwayland

      inputs.hyprhook.packages.x86_64-linux.hyprhook
      pkgs.unstable.hyprlandPlugins.hycov
    ];
  };
}
