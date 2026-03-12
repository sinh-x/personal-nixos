# Lily home config - Lenovo IdeaPad 3 15ADA05
# Bare minimum: browser, terminal, nixvim
{ pkgs, ... }:
{
  imports = [
    ./global
    ./niri-extras.nix
  ];

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
        chrome = false;
        brave = false;
      };
      utilities.enable = false;
      themes.enable = true;
      input-cfg.enable = true;
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
      utilities.enable = true;
      terminal = {
        ghostty.enable = true;
        kitty.enable = false;
        warp.enable = false;
      };
      shell.fish.enable = true;
      shell.zsh.enable = false;
      starship.enable = true;
      multiplexers.zellij.enable = false;
      editor.neovim.enable = true;
      backup.enable = false;
      nix.enable = true;
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

    personal-scripts.enable = false;
  };
}
