{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.gophertube;
in
{
  options.${namespace}.cli-apps.tools.gophertube = {
    enable = mkEnableOption "gophertube - A TUI for YouTube, written in Go";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.gophertube ];
  };
}
