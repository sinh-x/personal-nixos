{ ... }:
{
  imports = [ ./global ];

  sinh-x = {

    multimedia = {
      mpd.enable = true;
    };

    cli-apps = {
      terminal.kitty.enable = true;
      shell.fish.enable = true;
      multiplexers.zellij.enable = true;
      editor.neovim.enable = true;
    };

    social-apps = {
      discord = true;
      messenger = true;
      slack = true;
      viber = true;
      zoom = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    LEFT_MONITOR = "HDMI-1";
  };
}
