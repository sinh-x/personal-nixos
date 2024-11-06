{ pkgs, ... }:
{
  imports = [ ./global ];

  home.packages = with pkgs; [
    anydesk
    light
    aegisub
    acpilight
    sct # for setting color temperature
  ];

  sinh-x = {
    apps = {
      sinh-x.enable = true;
      web.browser.enable = true;
      utilities.enable = true;
      themes.enable = true;
      input-cfg.enable = true;
    };

    multimedia = {
      mpd.enable = true;
      utilities.enable = true;
      tools = {
        kdenlive.enable = true;
      };
    };

    cli-apps = {
      utilities.enable = true;
      terminal.kitty.enable = true;
      shell.fish.enable = true;
      multiplexers.zellij.enable = true;
      editor.neovim.enable = true;
      backup.enable = true;
      nix.enable = true;
    };

    social-apps = {
      discord = true;
      messenger = true;
      slack = true;
      viber = true;
      zoom = true;
    };

    security = {
      bitwarden.enable = true;
      sops.enable = true;
    };

    wm = {
      bspwm.enable = true;
    };

    personal-scripts.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    LEFT_MONITOR = "eDP-1";
  };
}
