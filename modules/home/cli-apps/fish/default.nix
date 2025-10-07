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
  cfg = config.${namespace}.cli-apps.shell.fish;
in
{
  options.${namespace}.cli-apps.shell.fish = {
    enable = mkEnableOption "Fish";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      loginShellInit = ''
        # ----- global sessions vars -----
      '';
      interactiveShellInit = ''
        eval "/home/sinh/.conda/bin/conda" "shell.fish" "hook" $argv | source
        auto_conda
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

        set show_file_or_dir_preview "if [ -d {} ]; lsd --tree --depth=2 --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end"

        set -x FZF_CTRL_T_OPTS "--preview '$show_file_or_dir_preview'"
        set -x FZF_ALT_C_OPTS "--preview 'lsd --tree --depth=2 --color=always {} | head -200'"

        # ----- Atuin -----
        atuin init fish --disable-up-arrow | source

        # ----- Bat (better cat) -----
        set -x BAT_THEME tokyonight_night

        # ----- Zoxide (better cd) ------
        zoxide init fish | source

        # ----- sinh path -----
        fish_add_path $HOME/.config/sinh-x-scripts

        # ----- sinh-x plugin -----
        set sinh_git_folders (/usr/bin/env cat ~/.config/sinh-x-scripts/sinh_git_folders.txt | read -z)

        bind yy fish_clipboard_copy
        bind \cp fish_clipboard_paste

        alias cat "bat"

        fish_vi_key_bindings

      '';
      shellInitLast = ''
        source ~/.config/sinh-x-scripts/global_sessions_vars.fish
      '';
      shellAbbrs = {
        # ----- git abbr -----
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

        # ----- ls abbr -----
        lsg = "ls | grep";
        llg = "ls -l | grep";
        lag = "ls -la | grep";

        sshref = "rm ~/.ssh/known_hosts";
      };
      shellAliases = {
        # ----- general alias -----
        vim = "nvim";
        ssha = "ssh-add";
        sshconfig = "nvim ~/.ssh/config";
      };
      functions = {
        check_conda = {
          body = ''
            if test -e .condaenv
                set env_name (cat .condaenv | string trim)

                if test -n "$env_name"
                    set current_env "$CONDA_DEFAULT_ENV"
                    if test -z "$current_env"
                        set current_env base
                    end

                    if not string match -q -- "$env_name" "$current_env"
                        echo "Activating Conda environment: $env_name"
                        conda activate "$env_name"
                    end
                end
            else
                if set -q CONDA_DEFAULT_ENV; and not string match -q -- "base" "$CONDA_DEFAULT_ENV"
                    echo "Deactivating Conda environment: $CONDA_DEFAULT_ENV"
                    conda deactivate
                end
            end
          '';
        };
        auto_conda = {
          # This tells fish to run this function when $PWD changes
          onVariable = "PWD";
          body = ''
            # Call the logic function
            check_conda
          '';
        };
      };
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
        {
          name = "ggl";
          src = pkgs.fetchFromGitHub {
            owner = "sinh-x";
            repo = "ggl.fish";
            rev = "c7bbaa33a68ed2033a543598f22dd9b9443805d6";
            sha256 = "YnkX18J/1KDW5C0JpWIDmAQD3dfxJ68OmVttgI0v0iE=";
          };
        }
      ];
    };
  };
}
