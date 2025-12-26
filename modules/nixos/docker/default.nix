{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    users.users.sinh.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
