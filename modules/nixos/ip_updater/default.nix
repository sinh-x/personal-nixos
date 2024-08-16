{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.ip_updater;
in
{
  options.services.ip_updater = {
    enable = mkEnableOption "ip_updater service";

    package = mkOption {
      type = types.package;
      default = pkgs.ip_update;
      description = "The package to use for the ip_updater service.";
    };

    wasabiAccessKeyFile = mkOption {
      type = types.path;
      default = "";
      description = "The file that contains the Wasabi access key for the ip_updater service.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ip_updater = {
      description = "Run ip_update";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/sinh-x-ip_updater";
        EnvironmentFile = cfg.wasabiAccessKeyFile;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.timers.ip_updater = {
      description = "Schedule ip_update 5mins after boot";
      timerConfig = {
        OnBootSec = "5min";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
