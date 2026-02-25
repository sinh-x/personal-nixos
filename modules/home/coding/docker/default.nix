{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.docker;
in
{
  options.${namespace}.coding.docker = {
    enable = mkEnableOption "Docker tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      docker
      docker-buildx
      docker-compose
    ];
  };
}
