{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.posting;
in
{
  options.${namespace}.cli-apps.tools.posting = {
    enable = mkEnableOption "posting - A powerful HTTP client that lives in your terminal";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.posting ];
  };
}
