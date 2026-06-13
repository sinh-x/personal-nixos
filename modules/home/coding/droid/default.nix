{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.droid;
in
{
  options.${namespace}.coding.droid = {
    enable = mkEnableOption "Factory Droid AI coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      droid
    ];
  };
}
