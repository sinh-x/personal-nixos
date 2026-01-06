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
  };
}
