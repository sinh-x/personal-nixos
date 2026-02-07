{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.devbox;
in
{
  options.${namespace}.coding.devbox = {
    enable = mkEnableOption "Devbox - isolated dev environments using Nix";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devbox
    ];
  };
}
