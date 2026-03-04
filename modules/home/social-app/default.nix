{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.social-apps;
in
{
  options = {
    ${namespace}.social-apps = {
      discord = mkEnableOption "Discord";
      messenger = mkEnableOption "Facebook Messenger";
      slack = mkEnableOption "Slack";
      viber = mkEnableOption "Viber";
      zca-listener = mkEnableOption "ZCA Listener";
      zoom = mkEnableOption "Zoom";
      element = mkEnableOption "Element";
      pidgin = mkEnableOption "Pidgin";
      telegram = mkEnableOption "Telegram";
      signal = mkEnableOption "Signal";
    };
  };

  config = {
    systemd.user.services.zca-listener = mkIf cfg.zca-listener {
      Unit = {
        Description = "ZCA Listener";
        After = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.zca-listener}/bin/zca-listener";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.packages = mkMerge [
      (mkIf cfg.discord [ pkgs.discord ])
      (mkIf cfg.messenger [ pkgs.caprine-bin ])
      (mkIf cfg.slack [ pkgs.slack ])
      (mkIf cfg.viber [ pkgs.viber ])
      (mkIf cfg.zca-listener [ pkgs.zca-listener ])
      (mkIf cfg.zoom [ pkgs.zoom-us ])
      (mkIf cfg.element [ pkgs.element-desktop ])
      (mkIf cfg.telegram [ pkgs.telegram-desktop ])
      (mkIf cfg.signal [
        pkgs.signal-desktop
        pkgs.signal-cli
      ])
      (mkIf cfg.pidgin [
        (pkgs.pidgin.override {
          plugins = [
            pkgs.purple-hangouts
            pkgs.purple-facebook
            pkgs.purple-matrix
          ];
        })
      ])
    ];
  };
}
