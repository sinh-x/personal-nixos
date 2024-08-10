{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.social-apps;
in {
  options = {
    programs.social-apps = {
      discord = mkEnableOption "Discord";
      messenger = mkEnableOption "Facebook Messenger";
      slack = mkEnableOption "Slack";
      viber = mkEnableOption "Viber";
      zoom = mkEnableOption "Zoom";
      element = mkEnableOption "Element";
    };
  };

  config = {
    home.packages = mkMerge [
      (mkIf cfg.discord [pkgs.discord])
      (mkIf cfg.messenger [pkgs.caprine-bin])
      (mkIf cfg.slack [pkgs.slack])
      (mkIf cfg.viber [pkgs.viber])
      (mkIf cfg.zoom [pkgs.zoom-us])
      (mkIf cfg.element [pkgs.element-desktop])
    ];
  };
}
