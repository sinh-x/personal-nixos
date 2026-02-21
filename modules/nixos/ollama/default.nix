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
    users.users.ollama = {
      isSystemUser = true;
      group = "ollama";
      home = "/persist/system/ollama";
      createHome = true;
    };
    users.groups.ollama = { };

    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      user = "ollama";
      group = "ollama";
      home = "/persist/system/ollama";
    };
  };
}
