# Drgnfly home config - Emberroot clone with impermanence
# This will be installed on the new 2TB SSD
{ pkgs, ... }:
{
  imports = [ ./global ];

  home = {
    packages = with pkgs; [
      anydesk
      light
      aegisub
      acpilight
      sct # for setting color temperature
      sound-theme-freedesktop # notification sounds
      mermaid-cli # mmdc - diagram generation from text
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
      anytype.enable = true;
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

    office.enable = true;

    multimedia = {
      mpd.enable = true;
      utilities.enable = true;
      tools = {
        kdenlive.enable = true;
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
      editor.vscode.enable = true;
      docker.enable = true;
      claudecode.enable = true;
      opencode.enable = true;
      super-productivity.enable = false;
      devbox.enable = true;
      flutter.enable = true;
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
          externalPosition = "left"; # External monitor to the left of primary
          externalMaxResolution = 4000;
        };
        workspaces.distribution = "split"; # 1-5,11-15 left; 6-10,16-20 right
      };
      hyprland.enable = false;
      niri = {
        enable = true;
        monitors.primary = "eDP-1";
      };
    };

    personal-scripts.enable = true;

    # Note: Full home persistence is handled by NixOS module (modules.impermanence.users)
    # To switch to selective persistence later, enable this and configure specific paths:
    # impermanence.enable = true;
  };
}
