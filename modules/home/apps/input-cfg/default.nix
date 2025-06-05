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
  cfg = config.${namespace}.apps.input-cfg;
in
{
  options.${namespace}.apps.input-cfg = {
    enable = mkEnableOption "Input method config - fcitx5";
  };

  config = mkIf cfg.enable {
    home = {
      sessionVariables = {
        IMSETTINGS_MODULE = "fcitx";
        INPUT_METHOD = "fcitx";
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        GLFW_IM_MODULE = "fcitx";
        XMODIFIERS = "@im=fcitx";
      };
    };
  };
}
