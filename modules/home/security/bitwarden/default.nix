{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.${namespace}.security.bitwarden;
in
{
  options.${namespace}.security.bitwarden = {
    enable = mkEnableOption "Bitwarden app";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ bitwarden-desktop ]; };
}
