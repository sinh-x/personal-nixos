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
  cfg = config.${namespace}.multimedia.tools.kdenlive;
in
{
  options.${namespace}.multimedia.tools.kdenlive = {
    enable = mkEnableOption "Kdenlive";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (libsForQt5.kdenlive.overrideAttrs (prevAttrs: {
        nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ makeBinaryWrapper ];
        postInstall =
          (prevAttrs.postInstall or "")
          + ''
            wrapProgram $out/bin/kdenlive --prefix LADSPA_PATH : ${rnnoise-plugin}/lib/ladspa
          '';
      }))
    ];
  };
}
