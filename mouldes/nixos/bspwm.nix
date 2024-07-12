{ config, pkgs, lib, ... }:

let
  cfg = config.modules.bspmw;
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
        sessionCommands = ''
          ${pkgs.bspwm}/bin/bspc wm -r
          source $HOME/.config/bspwm/bspwmrc
        '';
        };
        windowManager.bspwm = {
          enable = true;
          package = pkgs.bspwm;
          sxhkd = {
            package = pkgs.sxhkd;
          };
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
      polybar
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
