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
      terminal.kitty.enable = true;
      terminal.warp.enable = true;
      shell.fish.enable = true;
      multiplexers.zellij.enable = true;
      editor.neovim.enable = true;
      backup.enable = true;
      nix.enable = true;
      tools = {
        below.enable = true;
        gurk.enable = false; # Using NixOS module instead (modules.gurk)
      };
    };

    coding = {
      editor.vscode.enable = true;
      docker.enable = true;
      claudecode.enable = true;
    };

    social-apps = {
      discord = true;
      element = true;
      messenger = false;
      slack = true;
      viber = true;
      zoom = true;
      telegram = true;
    };

    security = {
      bitwarden.enable = true;
      sops.enable = true;
    };

    wm = {
      bspwm.enable = false;
      hyprland.enable = true;
    };

    personal-scripts.enable = true;
  };
}
