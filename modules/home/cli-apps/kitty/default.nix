{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.terminal.kitty;
in
{
  options.${namespace}.cli-apps.terminal.kitty = {
    enable = mkEnableOption "Kitty";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "xterm" ''
        ${lib.getExe config.programs.kitty.package} "$@"
      '')
    ];
    # I prefer to use ssh -M explicitly, thanks.
    xdg.configFile."kitty/ssh.conf".text = ''
      share_connections no
    '';
    xdg.mimeApps = {
      associations.added = {
        "x-scheme-handler/terminal" = "kitty.desktop";
      };
      defaultApplications = {
        "x-scheme-handler/terminal" = "kitty.desktop";
      };
    };
    programs.kitty = {
      enable = true;
      font = {
        name = "IosevkaTerm Nerd Font";
        size = 12;
      };
      extraConfig = ''
        # Include hypr-specific kitty config
        include ~/.config/hypr/kitty/kitty.conf

        confirm_os_window_close 0
        background_opacity 0.90
        dynamic_background_opacity yes
      '';
      keybindings = {
        "ctrl+enter" = "send_text normal clone-in-kitty --type os-window\\r";
      };
      settings = {
        # editor = config.home.sessionVariables.EDITOR;
        shell_integration = "no-rc";
        scrollback_lines = 4000;
        scrollback_pager_history_size = 100000;
        window_padding_width = 2;
      };
    };
  };
}
