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
    };
  };
}
