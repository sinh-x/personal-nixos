{
  lib,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.asciinema;
in
{
  options.${namespace}.cli-apps.tools.asciinema = {
    enable = mkEnableOption "asciinema - Terminal session recorder";
  };

  config = mkIf cfg.enable {
    programs.asciinema = {
      enable = true;
      settings = {
        "rec" = {
          idle_time_limit = 2;
        };
      };
    };
  };
}
