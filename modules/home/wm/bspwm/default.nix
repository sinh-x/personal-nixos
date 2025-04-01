{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.wm.bspwm;
in
{
  options.${namespace}.wm.bspwm = {
    enable = mkEnableOption "Bspwm config using hm";
  };

  config = mkIf cfg.enable {
    home.packages = [ ];

    home.file.".config/bspwm" = {
      source = ./bspwm_config;
      recursive = true;
    };

  };
}
