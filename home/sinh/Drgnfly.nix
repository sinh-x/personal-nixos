# Drgnfly home config - Emberroot clone with impermanence
# This will be installed on the new 2TB SSD
{ pkgs, ... }:
{
  imports = [
    ./global
    ./niri-extras.nix
  ];

  home = {
    packages = with pkgs; [
      anydesk
      brightnessctl
      aegisub
      nixos-anywhere
      acpilight
      sct # for setting color temperature
      sound-theme-freedesktop # notification sounds
      mermaid-cli # mmdc - diagram generation from text
      openai-whisper # speech-to-text recognition
      pa-core # PA platform core CLI
      opa # PA platform opencode adapter CLI
      obsidian
      logseq
      andafin-jira-mcp
      personal-google-mcp
      pi-coding-agent
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browser - Zen Twilight
      "x-scheme-handler/http" = "zen-twilight.desktop";
      "x-scheme-handler/https" = "zen-twilight.desktop";
      "x-scheme-handler/chrome" = "zen-twilight.desktop";
      "text/html" = "zen-twilight.desktop";
      "application/xhtml+xml" = "zen-twilight.desktop";
      "application/x-extension-htm" = "zen-twilight.desktop";
      "application/x-extension-html" = "zen-twilight.desktop";
      "application/x-extension-shtml" = "zen-twilight.desktop";
      "application/x-extension-xhtml" = "zen-twilight.desktop";
      "application/x-extension-xht" = "zen-twilight.desktop";
    };
  };

  sinh-x = {
    apps = {
      sinh-x = {
        enable = true;
        zeroclaw.enable = false;
      };
      web = {
        browser = {
          chrome = true;
          edge = true;
        };
        vivaldi.enable = true;
        zen-browser.enable = true;
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
        warp.enable = true;
      };
      shell.fish.enable = true;
      shell.zsh.enable = false;
      starship.enable = true;
      multiplexers.zellij.enable = true;
      multiplexers.herdr.enable = true;
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
      docker.enable = true;
      codex.enable = false;
      claudecode.enable = false;
      opencode.enable = true;
      droid.enable = true;
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
      zca-listener = true;
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
