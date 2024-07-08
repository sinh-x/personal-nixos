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

    plugins = with pkgs; [
      tmuxPlugins.tmux-fzf
      tmuxPlugins.resurrect
      tmuxPlugins.copycat
      tmuxPlugins.logging
      tmuxPlugins.sensible
      tmuxPlugins.yank
      tmuxPlugins.fzf-tmux-url
      tmuxPlugins.sessionist
      { 
        plugin = tmux-fzf-session-switch;
        extraConfig = ''
          set -g @fzf-goto-session 'f'
        '';
      }
      aw-watcher-tmux
      {
        plugin = tokyo-night-tmux;
        extraConfig = ''
          # now playing widget
          set -g @tokyo-night-tmux_show_music 1

          # netspeed widget
          set -g @tokyo-night-tmux_show_netspeed 1
          set -g @tokyo-night-tmux_netspeed_iface "wlo1" # detected via default route
          set -g @tokyo-night-tmux_netspeed_showip 1      # display ipv4 address (default 0)
          set -g @tokyo-night-tmux_netspeed_refresh 1     # update interval in seconds (default 1)
        '';
      }
      tmuxPlugins.continuum
    ];

    extraConfig = ''
      unbind C-b

      set -g prefix C-a
      bind C-a send-prefix


      # binding windowr navigation to alt+shift
      bind -n m-n previous-window
      bind -n m-e next-window

      ## set vi-mode
      set-window-option -g mode-keys vi

      # open panes in current working directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind '%' split-window -h -c "#{pane_current_path}"

      # tmux-logging config ---------------------------------
      set -g @logging-path "/home/sinh/synced-files/tmux-logs"
      set -g @save-complete-history-path "/home/sinh/synced-files/tmux-history"
      set -g @screen-capture-path "/home/sinh/pictures/tmux"

      # tmux resurrect ------------------------------------------
      set -g @resurrect-dir '/home/sinh/synced-files/tmux-sessions-sinh-desktop/'
    '';
  };
}
