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
      LEFT_MONITOR = "eDP-1";
    };
  };

  sinh-x = {
    apps = {
      web.browser.edge = true;
      utilities.enable = true;
      themes.enable = true;
      input-cfg.enable = true;
    };

    office.enable = true;

    cli-apps = {
      utilities.enable = true;
      terminal.kitty.enable = true;
      shell.fish.enable = true;
      nix.enable = true;
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
