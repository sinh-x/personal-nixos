{
  pkgs,
  libs,
  config,
  ...
}: let
  aw-watcher-tmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "aw-watcher-tmux";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "akohlbecker";
      repo = "aw-watcher-tmux";
      rev = "efaa7610add52bd2b39cd98d0e8e082b1e126487";
      sha256 = "";
    };
  };
in {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      tmux-fzf
      resurrect
      continuum
      copycat
      logging
      sensible
      yank
      fzf-tmux-url
      sessionist
      aw-watcher-tmux
    ];

    extraConfig = ''
      # # -- navigation ----------------------------------------------------------------
      # # smart pane switching with awareness of vim splits.
      # # see: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqe '^[^txz ]+ +(\\s+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'c-left' if-shell "$is_vim" 'send-keys c-left' 'select-pane -l'
      bind-key -n 'c-down' if-shell "$is_vim" 'send-keys c-down'  'select-pane -d'
      bind-key -n 'c-up' if-shell "$is_vim" 'send-keys c-up'  'select-pane -u'
      bind-key -n 'c-right' if-shell "$is_vim" 'send-keys c-right'  'select-pane -r'
      tmux_version='$(tmux -v | sed -en "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'c-\\' if-shell \"$is_vim\" 'send-keys c-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'c-\\' if-shell \"$is_vim\" 'send-keys c-\\\\'  'select-pane -l'"

      # binding windowr navigation to alt+shift
      bind -n m-n previous-window
      bind -n m-e next-window

      ## set vi-mode
      set-window-option -g mode-keys vi

      # keybindings
      bind-key -t copy-mode-vi v send-keys -x begin-selection
      bind-key -t copy-mode-vi c-v send-keys -x rectangle-toggle
      bind-key -t copy-mode-vi y send-keys -x copy-selection-and-cancel

      # open panes in current working directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind '%' split-window -h -c "#{pane_current_path}"

      ## join windows: <prefix> s, <prefix> j
      bind-key j command-prompt -p "join pane from:"  "join-pane -s '%%'"
      bind-key s command-prompt -p "send pane to:"  "join-pane -t '%%'"

      # tmux-logging config ---------------------------------
      set -g @logging-path "/home/sinh/synced-files/tmux-logs"
      set -g @save-complete-history-path "/home/sinh/synced-files/tmux-history"
      set -g @screen-capture-path "/home/sinh/pictures/tmux"

      # tokyo-night config ---------------------------------
      # now playing widget
      set -g @tokyo-night-tmux_show_music 1

      # netspeed widget
      set -g @tokyo-night-tmux_show_netspeed 1
      set -g @tokyo-night-tmux_netspeed_iface "wlo1" # detected via default route
      set -g @tokyo-night-tmux_netspeed_showip 1      # display ipv4 address (default 0)
      set -g @tokyo-night-tmux_netspeed_refresh 1     # update interval in seconds (default 1)

      # tmux-fzf-session-switch ---------------------------------
      set -g @fzf-goto-session 'f'

      # tmux resurrect ------------------------------------------
      set -g @resurrect-dir '/home/sinh/synced-files/tmux-sessions-sinh-desktop/'
    '';
  };
}
