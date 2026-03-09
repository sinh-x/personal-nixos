{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    username = "doangia";
    homeDirectory = "/home/doangia";

    packages = with pkgs; [
      sound-theme-freedesktop
    ];

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "microsoft-edge";
      LEFT_MONITOR = "eDP-1";
    };
  };

  sinh-x = {
    apps = {
      web.zen-browser.enable = true;
      web.browser.edge = true;
      utilities.enable = true;
      themes.enable = true;
      input-cfg.enable = true;
    };

    office.enable = true;

    multimedia.utilities.enable = true;

    cli-apps = {
      utilities.enable = true;
      terminal.kitty.enable = true;
      shell.fish.enable = true;
      starship.enable = true;
      editor.neovim.enable = true;
      nix.enable = true;
    };

    wm.niri = {
      enable = true;
      monitors.primary = "eDP-1";
    };
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
