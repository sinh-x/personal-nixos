{ config, pkgs, ... }:
{
  systemd.services.ip_updater = {
    description = "Run ip_update";
    serviceConfig = {
      ExecStart = "${pkgs.ip_update}/bin/ip_update";
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
}
