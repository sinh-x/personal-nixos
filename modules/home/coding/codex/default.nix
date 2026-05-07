{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.codex;
in
{
  options.${namespace}.coding.codex = {
    enable = mkEnableOption "OpenAI Codex CLI";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      codex
    ];
  };
}
