{
  pkgs,
  libs,
  config,
  ...
}: {
  programs.fish = {
    enable = true;
    shellInitLast = ''
      # Commands to run in interactive sessions can go here
      # ----- general alias -----
      # alias tmux "tmux -f ~/.config/tmux/tmux.conf"
      alias vim nvim
      alias ssha ssh-add
      alias sshconfig "nvim ~/.ssh/config"
      alias cat bat

      # ----- ls abbr -----
      abbr lsg "ls | grep"
      abbr llg "ls -l | grep"
      abbr lag "ls -la | grep"

      # ----- git abbr -----
      abbr g git
      abbr gs "git status"
      abbr ga "git add"
      abbr gc "git commit"
      abbr gcm "git commit -m"
      abbr gp "git push"
      abbr gpl "git pull"
      abbr gco "git checkout"
      abbr gb "git branch"
      abbr gba "git branch -a"
      abbr gbd "git branch -d"
      abbr gbm "git branch -m"
      abbr gl "git log"
      abbr gll "git log --oneline"
      abbr gd "git diff"
      abbr gds "git diff --staged"
      abbr gdc "git diff --cached"
      abbr gcl "git clone"
      abbr gcf "git config --list"
      abbr gsw "git switch"
      abbr lg lazygit

      alias sshref="rm ~/.ssh/known_hosts"

      # ----- FZF -----
      fzf --fish | source

      # --- setup fzf theme ---
      set fg "#CBE0F0"
      set bg "#011628"
      set bg_highlight "#143652"
      set purple "#B388FF"
      set blue "#06BCE4"
      set cyan "#2CF9ED"

      set -x FZF_DEFAULT_OPTS "--color=fg:$fg,bg:$bg,hl:$purple,fg+:$fg,bg+:$bg_highlight,hl+:$purple,info:$blue,prompt:$cyan,pointer:$cyan,marker:$cyan,spinner:$cyan,header:$cyan"

      # -- Use fd instead of fzf --
      set -x FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
      set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
      set -x FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

      set show_file_or_dir_preview "if [ -d {} ]; eza --tree --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end"

      set -x FZF_CTRL_T_OPTS "--preview '$show_file_or_dir_preview'"
      set -x FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

      # ----- Bat (better cat) -----
      set -x BAT_THEME tokyonight_night

      # ---- Eza (better ls) -----
      # alias ls "eza --icons=always"

      # ----- Zoxide (better cd) ------
      zoxide init fish | source
      alias cd z

      # ----- tmux.fish  ------
      set -Ux fish_tmux_autostart_once true
      set -Ux fish_tmux_autostart false
      set -Ux fish_tmux_autostarted false
      set -Ux fish_tmux_autoconnect true
      set -Ux fish_tmux_autoquit false
      set -Ux fish_tmux_config /home/sinh/.config/tmux.conf

      # ----- Tmux session wizard -----
      fish_add_path $HOME/.config/tmux/plugins/tmux-session-wizard/bin
      fish_add_path $HOME/.config/sinh-scripts

      # ----- sinh-x plugin -----
      set sinh_git_folders (/usr/bin/env cat ~/.config/sinh-x-local/sinh_git_folders.txt | read -z)
    '';
    plugins = [
      {
        name = "sinh-x.fish";
        src = pkgs.fetchFromGitHub {
          owner = "sinh-x";
          repo = "sinh-x.fish";
          rev = "c5c129444aa1308ea64b8174fe83b53e8e9fe9f8";
          sha256 = "IYWufjnAPWCd/A5o4zCt4fxVHIAqrdeY+4Y/cCK6Ioc=";
        };
      }
      {  name = "ggl";  
         src = pkgs.fetchFromGitHub {
           owner = "sinh-x";
           repo = "ggl.fish";
           rev = "c7bbaa33a68ed2033a543598f22dd9b9443805d6";
           sha256 = "YnkX18J/1KDW5C0JpWIDmAQD3dfxJ68OmVttgI0v0iE=";  
         };
      }
      {
        name = "tmux";
        src = pkgs.fetchFromGitHub {
          owner = "budimanjojo";
          repo = "tmux.fish";
          rev = "e95dbc11fa57d738cd837cb659d50b73ec0a8d90";
          sha256 = "tNq/F9NQZZ1pd0ZWPzQVwuHABCVECmXRN12ovGSUUFU=";
        };
      }
    ];
  };
}
