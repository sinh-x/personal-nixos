{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.wm.bspwm;

  # Create a wrapper script for starting bspwm session with sx
  bspwmSession = pkgs.writeShellScript "bspwm-session" ''
    # Source profile for environment
    [ -f /etc/profile ] && . /etc/profile
    [ -f ~/.profile ] && . ~/.profile

    # Start bspwm
    exec ${pkgs.bspwm}/bin/bspwm
  '';
in
{
  options.modules.wm.bspwm = {
    enable = lib.mkEnableOption "bspwm";

    greetd = {
      enable = lib.mkEnableOption "greetd display manager with bspwm";

      autoLogin = {
        enable = lib.mkEnableOption "auto-login without greeter";

        user = lib.mkOption {
          type = lib.types.str;
          default = "sinh";
          description = "User to auto-login as";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager.bspwm = {
        enable = true;
        package = pkgs.bspwm;
      };
      # Use sx for proper X session handling with greetd
      displayManager.sx.enable = lib.mkIf cfg.greetd.enable true;
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
      thunar
      gvfs
      lxappearance
      xorg.xev
      xorg.xinit
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];

    # greetd display manager
    services.greetd = lib.mkIf cfg.greetd.enable {
      enable = true;
      settings = {
        default_session =
          if cfg.greetd.autoLogin.enable then
            {
              command = "${pkgs.sx}/bin/sx ${bspwmSession}";
              inherit (cfg.greetd.autoLogin) user;
            }
          else
            {
              command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd '${pkgs.sx}/bin/sx ${bspwmSession}'";
              user = "greeter";
            };
      };
    };
  };
}
