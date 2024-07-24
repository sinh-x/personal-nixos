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

    systemd.user.services.rust-cli-pomodoro = {
      Unit = {
        AssertFileIsExecutable = "${cfg.package}/bin/pomodoro";
        Description = "pomodoro services";
        Documentation = "";
        PartOf = ["default.target"];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/pomodoro";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
