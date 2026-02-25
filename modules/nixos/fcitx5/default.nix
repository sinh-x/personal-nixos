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
    modules.fcitx5.lotus = {
      enable = lib.mkEnableOption "fcitx5-lotus Vietnamese input";
      user = lib.mkOption {
        type = lib.types.str;
        default = "sinh";
        description = "User to run the fcitx5-lotus-server for";
      };
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        i18n.inputMethod = {
          enable = true;
          type = "fcitx5";
          fcitx5.addons = with pkgs; [
            fcitx5-mozc
            fcitx5-gtk
            fcitx5-rime
            kdePackages.fcitx5-qt # qt6
            kdePackages.fcitx5-unikey
            fcitx5-bamboo
            qt6Packages.fcitx5-configtool
            qt6Packages.fcitx5-chinese-addons
          ];
        };
      }

      (lib.mkIf cfg.lotus.enable {
        i18n.inputMethod.fcitx5.addons = [ pkgs.fcitx5-lotus ];

        users.users.uinput_proxy = {
          isSystemUser = true;
          group = "input";
        };

        services.udev.packages = [ pkgs.fcitx5-lotus ];
        systemd.packages = [ pkgs.fcitx5-lotus ];
        systemd.targets.multi-user.wants = [ "fcitx5-lotus-server@${cfg.lotus.user}.service" ];
      })
    ]
  );
}
