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
      sha256 = "sha256-L6YLyEOmb+vdz6bJdB0m5gONPpBp2fV3i9PiLSNrZNM=";
    };
  };
  tmux-fzf-session-switch = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-fzf-session-switch";
    version = "v2.";
    src = pkgs.fetchFromGitHub {
      owner = "brokenricefilms";
      repo = "tmux-fzf-session-switch";
      rev = "v2.1";
      sha256 = "sha256-T2fyvpygaZ22DlgBLR9fGH8w9JLsooNLT6+W4mdDBQ4=";
    };
  };
  tokyo-night-tmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tokyo-night-tmux";
    version = "v1.5.5";
    src = pkgs.fetchFromGitHub {
      owner = "janoamaral";
      repo = "tokyo-night-tmux";
      rev = "v1.5.5";
      sha256 = "sha256-ATaSfJSg/Hhsd4LwoUgHkAApcWZV3O3kLOn61r1Vbag=";
    };
  };
in {
  programs.tmux = {
    enable = true;
    prefix = "C-a";

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
      tmux-fzf-session-switch
      aw-watcher-tmux
      tokyo-night-tmux
    ];

    extraConfig = ''

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
