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
  cfg = config.${namespace}.multimedia.mpd;
in
{
  options.${namespace}.multimedia.mpd = {
    enable = mkEnableOption "mpd and mpc";
  };

  config = mkIf cfg.enable {
    services.mpd = {
      enable = true;
      musicDirectory = "~/Music";
    };

    programs.ncmpcpp = {
      enable = true;
    };

    home.packages = with pkgs; [ mpc ];
  };
}
