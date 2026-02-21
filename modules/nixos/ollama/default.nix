{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.ollama;
in
{
  options.modules.ollama = {
    enable = mkEnableOption "ollama local LLM server";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
