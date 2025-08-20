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
  cfg = config.${namespace}.apps.web.browser;
in
{
  options.${namespace}.apps.web.browser = {
    enable = mkEnableOption "Web browser apps";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      floorp
      firefox
      google-chrome
      # microsoft-edge
      # opera

    ];

    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http" = [ "userapp-Zen-XKRIA3.desktop" ];
      "x-scheme-handler/https" = [ "userapp-Zen-XKRIA3.desktop" ];
      "x-scheme-handler/chrome" = [ "userapp-Zen-XKRIA3.desktop" ];
      "text/html" = [ "userapp-Zen-XKRIA3.desktop" ];
      "application/x-extension-htm" = [ "userapp-Zen-XKRIA3.desktop" ];
      "application/x-extension-html" = [ "userapp-Zen-XKRIA3.desktop" ];
      "application/x-extension-shtml" = [ "userapp-Zen-XKRIA3.desktop" ];
      "application/xhtml+xml" = [ "userapp-Zen-XKRIA3.desktop" ];
      "application/x-extension-xhtml" = [ "userapp-Zen-XKRIA3.desktop" ];
      "application/x-extension-xht" = [ "userapp-Zen-XKRIA3.desktop" ];
    };

    home.sessionVariables = {
      BROWSER = "/run/current-system/sw/bin/zen";
    };

  };
}
