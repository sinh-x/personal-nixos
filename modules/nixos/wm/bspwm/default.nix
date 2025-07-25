{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.wm.bspwm;
in
{
  options = {
    modules.wm.bspwm.enable = lib.mkEnableOption "bspwm";
  };
  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        windowManager.bspwm = {
          enable = true;
          package = pkgs.bspwm;
        };
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    environment.systemPackages = with pkgs; [
      betterlockscreen
      copyq
      dmenu
      dunst
      feh
      flameshot
      gsettings-qt
      gsimplecal
      gtk3
      pastel
      # input-leap
      killall
      libnotify
      polybarFull
      pamixer
      pulsemixer
      rofi
      screenkey
      sxhkd
      xclip
      xcolor
      xdg-utils
      xdo
      xdotool
      xfce.thunar
      gvfs
      lxappearance
      xorg.xev
      xorg.xinit
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];
  };
}
