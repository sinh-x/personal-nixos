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

      backup.enable = false;
      nix.enable = false;
      tools = {
        asciinema.enable = false;
        below.enable = false;

      };
    };

    coding = {
      editor.vscode.enable = false;
      docker.enable = false;
      claudecode.enable = false;

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
      niri = {
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

    personal-scripts.enable = false;
  };
}
