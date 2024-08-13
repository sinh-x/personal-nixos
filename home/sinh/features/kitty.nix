{
  config,
  pkgs,
  lib,
  ...
}:
let

  colors = {
    foreground = "#a9b1d6";
    background = "#1a1b26";
    cursor = "#c0caf5";
    cursor_text_color = "#1a1b26";
    selection_background = "#28344a";
    selection_foreground = "#c0caf5";
    url_color = "#9ece6a";
    color0 = "#414868";
    color8 = "#414868";
    color1 = "#f7768e";
    color9 = "#f7768e";
    color2 = "#73daca";
    color10 = "#73daca";
    color3 = "#e0af68";
    color11 = "#e0af68";
    color4 = "#7aa2f7";
    color12 = "#7aa2f7";
    color5 = "#bb9af7";
    color13 = "#bb9af7";
    color6 = "#7dcfff";
    color14 = "#7dcfff";
    color7 = "#c0caf5";
    color15 = "#c0caf5";
    active_border_color = "#3d59a1";
    inactive_border_color = "#101014";
    bell_border_color = "#e0af68";
    tab_bar_background = "#101014";
    active_tab_foreground = "#3d59a1";
    active_tab_background = "#16161e";
    active_tab_font_style = "bold";
    inactive_tab_foreground = "#787c99";
    inactive_tab_background = "#16161e";
    inactive_tab_font_style = "bold";
    macos_titlebar_color = "#16161e";
  };

in
{
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
      foreground = "${colors.foreground}";
      background = "${colors.background}";
      selection_background = "${colors.selection_background}";
      selection_foreground = "${colors.selection_foreground}";
      url_color = "${colors.url_color}";
      cursor = "${colors.cursor}";
      cursor_text_color = "${colors.cursor_text_color}";
      color0 = "${colors.color0}";
      color1 = "${colors.color1}";
      color2 = "${colors.color2}";
      color3 = "${colors.color3}";
      color4 = "${colors.color4}";
      color5 = "${colors.color5}";
      color6 = "${colors.color6}";
      color7 = "${colors.color7}";
      color8 = "${colors.color8}";
      color9 = "${colors.color9}";
      color10 = "${colors.color10}";
      color11 = "${colors.color11}";
      color12 = "${colors.color12}";
      color13 = "${colors.color13}";
      color14 = "${colors.color14}";
      color15 = "${colors.color15}";
      active_border_color = "${colors.active_border_color}";
      inactive_border_color = "${colors.inactive_border_color}";
      bell_border_color = "${colors.bell_border_color}";
      tab_bar_background = "${colors.tab_bar_background}";
      active_tab_foreground = "${colors.active_tab_foreground}";
      active_tab_background = "${colors.active_tab_background}";
      active_tab_font_style = "${colors.active_tab_font_style}";
      inactive_tab_foreground = "${colors.inactive_tab_foreground}";
      inactive_tab_background = "${colors.inactive_tab_background}";
      inactive_tab_font_style = "${colors.inactive_tab_font_style}";
      macos_titlebar_color = "${colors.macos_titlebar_color}";
    };
  };
}
