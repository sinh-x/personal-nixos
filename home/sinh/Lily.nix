# Lily home config - Lenovo IdeaPad 3 15ADA05
# Minimal: Edge browser, ghostty terminal, niri WM only
{ pkgs, ... }:
{
  imports = [
    ./global
    ./niri-extras.nix
  ];

  home = {
    packages = with pkgs; [
      brightnessctl
      acpilight
      sct
      sound-theme-freedesktop
    ];

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "microsoft-edge";
      LEFT_MONITOR = "eDP-1";
    };

    sessionPath = [
      "$HOME/.cargo/bin"
    ];
  };

  sinh-x = {
    apps = {
      sinh-x.enable = false;
      web.zen-browser.enable = false;
      web.browser = {
        chrome = false;
        brave = false;
        edge = true;
      };
      utilities.enable = false;
      themes.enable = false;
      input-cfg.enable = false;
    };

    office.enable = false;

    multimedia = {
      mpd.enable = false;
      utilities.enable = false;
      tools = {
        kdenlive.enable = false;
      };
    };

    cli-apps = {
      utilities.enable = false;
      terminal = {
        ghostty.enable = true;
        kitty.enable = false;
        warp.enable = false;
      };
      shell.fish.enable = false;
      shell.zsh.enable = false;
      starship.enable = false;
      multiplexers.zellij.enable = false;
      editor.neovim.enable = false;
      backup.enable = false;
      nix.enable = false;
      tools = {
        asciinema.enable = false;
        below.enable = false;
        gurk.enable = false;
      };
    };

    coding = {
      editor.vscode.enable = false;
      docker.enable = false;
      claudecode.enable = false;
      super-productivity.enable = false;
      devbox.enable = false;
      flutter.enable = false;
    };

    social-apps = {
      discord = false;
      element = false;
      messenger = false;
      slack = false;
      viber = false;
      zoom = false;
      telegram = false;
      signal = false;
    };

    security = {
      bitwarden.enable = false;
      sops.enable = false;
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

    personal-scripts.enable = false;
  };
}
