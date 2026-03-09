{
  inputs,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  home = {
    username = "doangia";
    homeDirectory = "/home/doangia";

    sessionVariables = {
      BROWSER = "microsoft-edge";
    };
  };

  sinh-x = {
    apps.web.zen-browser.enable = true;
    apps.web.browser.edge = true;
    office.enable = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "microsoft-edge.desktop";
      "x-scheme-handler/https" = "microsoft-edge.desktop";
      "text/html" = "microsoft-edge.desktop";
    };
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home.stateVersion = "24.05";
}
