{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.apps.anytype;
in
{
  options.${namespace}.apps.anytype = {
    enable = mkEnableOption "Anytype CLI headless server";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.sinh-x.anytype-cli ];

    systemd.user.services.anytype-cli = {
      Unit = {
        Description = "Anytype CLI headless server";
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.sinh-x.anytype-cli}/bin/anytype-cli serve";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
