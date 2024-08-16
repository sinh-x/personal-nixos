{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.fcitx5;
in
{
  options = {
    modules.fcitx5.enable = lib.mkEnableOption "fcitx5 inputMethod";
  };
  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        libsForQt5.fcitx5-unikey
      ];
    };
  };
}
