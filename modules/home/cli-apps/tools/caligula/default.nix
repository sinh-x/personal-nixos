{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.caligula;
in
{
  options.${namespace}.cli-apps.tools.caligula = {
    enable = mkEnableOption "caligula - A user-friendly, lightweight TUI for disk imaging";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.caligula ];
  };
}
