{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.r_setup;
in
{
  options = {
    modules.python.enable = lib.mkEnableOption "Python installation";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      python39
      conda
    ];
  };
}
