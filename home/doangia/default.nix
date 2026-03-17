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
    username = "doangia";
    homeDirectory = "/home/doangia";

    packages = with pkgs; [
      sound-theme-freedesktop
    ];

    sessionVariables = {
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
    };
  };

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
