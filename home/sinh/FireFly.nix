# FireFly home config - portable NixOS on USB
# Minimal: CLI tools, browser, niri. No social apps, no office.
{ ... }:
{
  imports = [
    ./global
    ./niri-extras.nix
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "zen-twilight";
    };
  };

  sinh-x = {
    apps = {
      web.zen-browser.enable = true;
      web.browser.edge = true;
      themes.enable = true;
      input-cfg.enable = true;
    };

    cli-apps = {
      utilities.enable = true;
      terminal.ghostty.enable = true;
      shell.fish.enable = true;
      starship.enable = true;
      multiplexers.zellij.enable = true;
      editor.neovim.enable = true;
      nix.enable = true;
    };

    coding = {
      claudecode.enable = true;
    };

    security = {
      bitwarden.enable = true;
      sops.enable = true;
    };

    wm.niri = {
      enable = true;
      monitors.primary = "eDP-1";
      startupScript = ''
        #!/usr/bin/env bash
        while ! niri msg --json outputs &>/dev/null 2>&1; do
            sleep 0.2
        done
        ~/.config/niri/scripts/workspace_monitors
        sleep 1
        niri msg action focus-workspace "main-term"
        exec ghostty
      '';
    };
  };
}
