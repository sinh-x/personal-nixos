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
  cfg = config.${namespace}.cli-apps.backup;
in
{
  options.${namespace}.cli-apps.backup = {
    enable = mkEnableOption "CLI Utilities apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rclone
      rustic
    ];

    services.syncthing = {
      enable = true;
      tray = {
        enable = false;
        command = "syncthing-tray";
        package = pkgs.syncthing-tray;
      };
    };

    # Rustic backup timer - runs once per night between 19:00-23:59
    systemd.user.services.rustic-backup = {
      Unit = {
        Description = "Rustic backup for personal files";
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.rustic}/bin/rustic -P sinh-personal_file backup /home/sinh";
        # Use nice to reduce system impact during backup
        Nice = 10;
        # Kill the backup if it runs for more than 2 hours
        TimeoutStartSec = "2h";
      };
    };

    systemd.user.timers.rustic-backup = {
      Unit = {
        Description = "Rustic backup timer";
      };

      Timer = {
        # Run once per night between 19:00-23:59
        # RandomizedDelaySec spreads the start time randomly within the 5-hour window
        OnCalendar = "19:00";
        RandomizedDelaySec = "4h 59m";
        # If the computer was off when the timer should have run, run it on next boot
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
