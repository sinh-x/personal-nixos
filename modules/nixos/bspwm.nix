{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.bspwm;
in {
  options = {
    modules.bspwm.enable = lib.mkEnableOption "bspwm";
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
      input-leap
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
      xorg.xev
      xorg.xinit
    ];
  };
}
