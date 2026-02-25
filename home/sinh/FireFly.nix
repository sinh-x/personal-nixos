# FireFly home config - portable NixOS daily driver on 128GB USB
# Based on Drgnfly, lighter (no office, no heavy coding tools)
{ pkgs, ... }:
{
  imports = [ ./global ];

  home = {
    packages = with pkgs; [
      light
      acpilight
      sct
      sound-theme-freedesktop
    ];

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "zen-twilight";
      LEFT_MONITOR = "eDP-1";
    };

    sessionPath = [
      "$HOME/.cargo/bin"
    ];
  };

  sinh-x = {
    apps = {
      sinh-x.enable = true;
      web.zen-browser.enable = true;
      web.browser = {
        chrome = true;
        brave = true;
      };
      utilities.enable = true;
      themes.enable = true;
      input-cfg.enable = true;
    };

    office.enable = false;

    multimedia = {
      mpd.enable = true;
      utilities.enable = true;
      tools = {
        kdenlive.enable = false;
      };
    };

    cli-apps = {
      utilities.enable = true;
      terminal = {
        ghostty.enable = true;
        kitty.enable = true;
        warp.enable = false;
      };
      shell.fish.enable = true;
      shell.zsh.enable = false;
      starship.enable = true;
      multiplexers.zellij.enable = true;
      editor.neovim.enable = true;
      backup.enable = true;
      nix.enable = true;
      tools = {
        asciinema.enable = true;
        below.enable = true;
        gurk.enable = false;
      };
    };

    coding = {
      editor.vscode.enable = false;
      docker.enable = false;
      claudecode.enable = true;
      super-productivity.enable = false;
      devbox.enable = false;
      flutter.enable = false;
    };

    social-apps = {
      discord = true;
      element = true;
      messenger = false;
      slack = false;
      viber = true;
      zoom = true;
      telegram = true;
      signal = true;
    };

    security = {
      bitwarden.enable = true;
      sops.enable = true;
    };

    wm = {
      bspwm = {
        enable = false;
        monitors = {
          primary = "eDP-1";
          externalPosition = "left";
          externalMaxResolution = 4000;
        };
        workspaces.distribution = "split";
      };
      hyprland.enable = false;
      niri = {
        enable = true;
        monitors.primary = "eDP-1";
      };
    };

    personal-scripts.enable = true;
  };
}
