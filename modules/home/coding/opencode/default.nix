{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.opencode;
in
{
  options.${namespace}.coding.opencode = {
    enable = mkEnableOption "OpenCode AI coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      opencode
    ];
  };
}
