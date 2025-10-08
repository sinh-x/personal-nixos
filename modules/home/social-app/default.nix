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
      zoom = mkEnableOption "Zoom";
      element = mkEnableOption "Element";
      pidgin = mkEnableOption "Pidgin";
      telegram = mkEnableOption "Telegram";
    };
  };

  config = {
    home.packages = mkMerge [
      (mkIf cfg.discord [ pkgs.discord ])
      (mkIf cfg.messenger [ pkgs.caprine-bin ])
      (mkIf cfg.slack [ pkgs.slack ])
      (mkIf cfg.viber [ pkgs.viber ])
      (mkIf cfg.zoom [ pkgs.zoom-us ])
      (mkIf cfg.element [ pkgs.element-desktop ])
      (mkIf cfg.telegram [ pkgs.telegram-desktop ])
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
