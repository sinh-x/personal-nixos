{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.shell.zsh;
in
{
  options.${namespace}.cli-apps.shell.zsh = {
    enable = mkEnableOption "ZSH";
  };

  config = mkIf cfg.enable {
    programs = {
      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      atuin = {
        enable = true;
        enableZshIntegration = true;
        flags = [ "--disable-up-arrow" ]; # Use Ctrl+R instead, keep up-arrow for normal history
        settings = {
          auto_sync = true;
          sync_frequency = "5m";
          search_mode = "fuzzy";
          filter_mode = "global";
          style = "compact";
          inline_height = 20;
          show_preview = true;
          history_filter = [
            "^ls"
            "^cd"
            "^exit"
          ];
        };
      };

      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        history = {
          size = 10000;
          save = 10000;
          ignoreDups = true;
          ignoreAllDups = true;
          ignoreSpace = true;
          share = true;
        };

        defaultKeymap = "viins";

        completionInit = ''
          autoload -U compinit && compinit
          zmodload zsh/complist
        '';

        initExtra = ''
          # ----- Completion settings -----
          # Case-insensitive and partial matching
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

          # Menu-driven completion
          zstyle ':completion:*' menu select
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

          # Group completions by category
          zstyle ':completion:*' group-name '''
          zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
          zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

          # Cache completions for speed
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

          # Complete . and .. directories
          zstyle ':completion:*' special-dirs true

          # Process completion
          zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
          zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

          # ----- Bat (better cat) -----
          export BAT_THEME="tokyonight_night"

          # ----- sinh path -----
          path+=("$HOME/.config/sinh-x-scripts")

          # ----- Vi mode improvements -----
          bindkey -v
          export KEYTIMEOUT=1

          # Edit line in vim with ctrl-e
          autoload edit-command-line
          zle -N edit-command-line
          bindkey '^e' edit-command-line

          # Use vim keys in tab complete menu
          bindkey -M menuselect 'h' vi-backward-char
          bindkey -M menuselect 'k' vi-up-line-or-history
          bindkey -M menuselect 'l' vi-forward-char
          bindkey -M menuselect 'j' vi-down-line-or-history
          bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift-Tab

          # Clipboard
          bindkey -M vicmd 'yy' vi-yank-whole-line

          # ----- Per-directory history -----
          # Toggle with Ctrl+G: local (per-directory) vs global history
          # Default: per-directory history

          # Source global session vars if exists
          [[ -f ~/.config/sinh-x-scripts/global_sessions_vars.zsh ]] && source ~/.config/sinh-x-scripts/global_sessions_vars.zsh
        '';

        shellAliases = {
          # ----- git aliases -----
          gs = "git status";
          ga = "git add";
          gc = "git commit";
          gcm = "git commit -m";
          gp = "git push";
          gpl = "git pull";
          gco = "git checkout";
          gb = "git branch";
          gba = "git branch -a";
          gbd = "git branch -d";
          gbm = "git branch -m";
          gl = "git log";
          gll = "git log --oneline";
          gd = "git diff";
          gds = "git diff --staged";
          gdc = "git diff --cached";
          gcl = "git clone";
          gcf = "git config --list";
          gsw = "git switch";
          lg = "lazygit";

          # ----- ls aliases -----
          lsg = "ls | grep";
          llg = "ls -l | grep";
          lag = "ls -la | grep";

          # ----- general aliases -----
          vim = "nvim";
          cat = "bat";
          ssha = "ssh-add";
          sshref = "rm ~/.ssh/known_hosts";
          sshconfig = "nvim ~/.ssh/config";
          anytype = "flatpak run io.anytype.anytype";
        };

        plugins = [
          {
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
          {
            name = "fzf-tab";
            src = pkgs.zsh-fzf-tab;
            file = "share/fzf-tab/fzf-tab.plugin.zsh";
          }
          {
            name = "per-directory-history";
            src = pkgs.fetchFromGitHub {
              owner = "jimhester";
              repo = "per-directory-history";
              rev = "master";
              sha256 = "sha256-VHRgrVCqzILqOes8VXGjSgLek38BFs9eijmp0JHtD5Q=";
            };
          }
        ];
      };
    };
  };
}
