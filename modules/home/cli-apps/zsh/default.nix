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
          # Add custom completions to fpath
          fpath=(~/.config/zsh/completions $fpath)
          autoload -U compinit && compinit
          zmodload zsh/complist
        '';

        initContent = ''
          # ----- Atuin + zsh-vi-mode fix -----
          # zsh-vi-mode overrides keybindings, so re-bind after it loads
          zvm_after_init() {
            eval "$(atuin init zsh --disable-up-arrow)"
            # Re-bind directory navigation (zvm may override)
            bindkey '^[[1;3D' _dirstack_prev
            bindkey '^[[1;3C' _dirstack_next
            bindkey '^[^[[D' _dirstack_prev
            bindkey '^[^[[C' _dirstack_next
          }

          # ----- Completion settings -----
          # Case-insensitive and partial matching
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

          # Menu-driven completion (disabled - fzf-tab handles this)
          # zstyle ':completion:*' menu select
          zstyle ':completion:*' menu no
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

          # Group completions by category
          zstyle ':completion:*' group-name '''
          zstyle ':completion:*:descriptions' format '[%d]'
          zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

          # Cache completions for speed
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

          # Complete . and .. directories
          zstyle ':completion:*' special-dirs true

          # Process completion
          zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
          zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

          # ----- fzf-tab settings -----
          # Switch group with < and >
          zstyle ':fzf-tab:*' switch-group '<' '>'
          # Show description in a separate column
          zstyle ':fzf-tab:*' show-group full
          # Continuous completion
          zstyle ':fzf-tab:*' continuous-trigger '/'

          # ----- Zellij session completion -----
          # Function to list zellij sessions for completion
          _zellij_list_sessions() {
            local -a sessions
            sessions=("''${(@f)$(command zellij list-sessions --short --no-formatting 2>/dev/null)}")
            compadd -a sessions
          }

          # Register completion for zellij attach/kill/delete subcommands
          # This runs after the main _zellij completion is loaded
          _zellij_session_completion() {
            case "$words[2]" in
              attach|a|kill-session|k|delete-session|d)
                if (( CURRENT == 3 )); then
                  _zellij_list_sessions
                  return
                fi
                ;;
            esac
            _zellij "$@"
          }
          compdef _zellij_session_completion zellij

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

          # ----- Directory stack (like fish prevd/nextd) -----
          setopt AUTO_PUSHD           # cd automatically pushes to stack
          setopt PUSHD_IGNORE_DUPS    # No duplicates in stack
          setopt PUSHD_SILENT         # Don't print stack after pushd/popd
          DIRSTACKSIZE=20             # Keep 20 directories in stack

          # Functions for directory navigation (as ZLE widgets)
          function _dirstack_prev {
            [[ $#dirstack -eq 0 ]] && return
            builtin pushd -q +1 2>/dev/null
            zle reset-prompt
          }
          function _dirstack_next {
            [[ $#dirstack -eq 0 ]] && return
            builtin pushd -q -1 2>/dev/null
            zle reset-prompt
          }
          zle -N _dirstack_prev
          zle -N _dirstack_next

          # Bind Alt+Left/Right - multiple sequences for terminal compatibility
          # Test your terminal with: cat -v, then press the key combo
          bindkey '^[[1;3D' _dirstack_prev  # Alt+Left (xterm)
          bindkey '^[[1;3C' _dirstack_next  # Alt+Right (xterm)
          bindkey '^[^[[D' _dirstack_prev   # Alt+Left (some terminals)
          bindkey '^[^[[C' _dirstack_next   # Alt+Right (some terminals)
          bindkey '\e[1;3D' _dirstack_prev  # Alt+Left (alternate)
          bindkey '\e[1;3C' _dirstack_next  # Alt+Right (alternate)

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
              sha256 = "sha256-EV9QPBndwAWzdOcghDXrIIgP0oagVMOTyXzoyt8tXRo=";
            };
          }
        ];
      };
    };
  };
}
