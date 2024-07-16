{ config, pkgs, lib, ... }:

let
  cfg = config.modules.bspwm;
in {
  options = {
    modules.bspwm.enable = lib.mkEnableOption "R and r-packages installation";
  };
  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          lightdm = {
            enable = true;
            greeters.gtk.enable = true;
          };
        };
        windowManager.bspwm = {
          enable = true;
          package = pkgs.bspwm;
        };
      };
    displayManager.defaultSession = "none+bspwm";
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
