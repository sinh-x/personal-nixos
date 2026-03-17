{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    username = "vy";
    homeDirectory = "/home/vy";

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
      web.browser.edge = true;
      themes.enable = false;
      input-cfg.enable = false;
    };

    social-apps.telegram = false;

    office.enable = false;

    cli-apps = {
      utilities.enable = false;
      terminal.kitty.enable = false;
      shell.fish.enable = false;
      nix.enable = false;
    };

    wm.niri = {
      enable = true;
      monitors.primary = "eDP-1";
      startupScript = ''
        #!/usr/bin/env bash
        while ! niri msg --json outputs &>/dev/null 2>&1; do sleep 0.2; done
        microsoft-edge &
        sleep 2
        niri msg action focus-workspace "main-term"
        exec ghostty
      '';
      extraWindowRules = ''
        window-rule {
            match app-id="microsoft-edge"
            open-on-workspace "main-browser"
        }
      '';
    };
  };

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
