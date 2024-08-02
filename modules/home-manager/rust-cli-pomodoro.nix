{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.rust-cli-pomodoro;
in {
  options.services.rust-cli-pomodoro = {
    enable = mkEnableOption "Auto start the pomodoro";

    package = mkOption {
      type = types.package;
      default = pkgs.rust-cli-pomodoro;
      description = "The package provide pomodoro";
    };
  };

  config = mkIf cfg.enable {
    assertions = [(hm.assertions.assertPlatform "services.rust-cli-pomodoro" pkgs platforms.linux)];

    systemd.user.services.pomodoro-cli = {
      Unit = {
        AssertFileIsExecutable = "${cfg.package}/bin/daemon";
        Description = "pomodoro services";
        Documentation = "A pmodooro cli tool";
        PartOf = ["default.target"];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/daemon";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
