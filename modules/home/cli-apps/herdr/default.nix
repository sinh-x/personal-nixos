{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.multiplexers.herdr;
in
{
  options.${namespace}.cli-apps.multiplexers.herdr = {
    enable = mkEnableOption "Herdr terminal multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.herdr ];

    xdg.configFile."herdr/config.toml".source = ./config.toml;
  };
}
