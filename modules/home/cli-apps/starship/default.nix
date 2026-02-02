{
  lib,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.starship;
in
{
  options.${namespace}.cli-apps.starship = {
    enable = mkEnableOption "Starship prompt";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;

        format = concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "\${custom.git_branch_colored}"
          "$git_status"
          "$nix_shell"
          "$direnv"
          "$docker_context"
          "$python"
          "$nodejs"
          "$rust"
          "$golang"
          "$rlang"
          "$jobs"
          "$status"
          "$cmd_duration"
          "$time"
          "$line_break"
          "$character"
        ];

        # SSH & User Awareness
        username = {
          show_always = false;
          style_user = "bold blue";
          style_root = "bold red";
          format = "[$user]($style)";
        };

        hostname = {
          ssh_only = true;
          style = "bold yellow";
          format = "@[$hostname]($style) ";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
          vimcmd_replace_one_symbol = "[❮](bold purple)";
          vimcmd_replace_symbol = "[❮](bold purple)";
          vimcmd_visual_symbol = "[❮](bold yellow)";
        };

        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          style = "bold cyan";
          read_only = " 󰌾";
          read_only_style = "red";
        };

        # Disable default git_branch - using custom module instead
        git_branch = {
          disabled = true;
        };

        # Custom git branch with dynamic colors based on repo state
        # Green = clean, Orange = modified only, Red = untracked files
        custom.git_branch_colored = {
          command = ''
            branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
            if [ -n "$branch" ]; then
              untracked=$(git status --porcelain 2>/dev/null | grep "^??" | head -1)
              modified=$(git status --porcelain 2>/dev/null | grep -v "^??" | head -1)
              if [ -n "$untracked" ]; then
                printf '\033[1;38;2;255;85;85m %s\033[0m' "$branch"
              elif [ -n "$modified" ]; then
                printf '\033[1;38;2;255;184;108m %s\033[0m' "$branch"
              else
                printf '\033[1;38;2;80;250;123m %s\033[0m' "$branch"
              fi
            fi
          '';
          when = "git rev-parse --git-dir 2>/dev/null";
          format = "$output ";
          shell = [
            "bash"
            "--noprofile"
            "--norc"
          ];
        };

        git_status = {
          format = "($conflicted$stashed$deleted$renamed$modified$untracked$staged$ahead_behind )";
          conflicted = "[=$count](bold #FF5555)";
          ahead = "[⇡$count](bold #8BE9FD)";
          behind = "[⇣$count](bold #8BE9FD)";
          diverged = "[⇕⇡$ahead_count⇣$behind_count](bold #8BE9FD)";
          untracked = "[?$count](bold #FF5555)";
          stashed = "[\\$$count](bold #BD93F9)";
          modified = "[!$count](bold #FFB86C)";
          staged = "[+$count](bold #50FA7B)";
          renamed = "[»$count](bold #FFB86C)";
          deleted = "[✘$count](bold #FF5555)";
        };

        nix_shell = {
          symbol = " ";
          style = "bold blue";
          impure_msg = "impure";
          pure_msg = "pure";
          unknown_msg = "";
          format = "via [$symbol$state( \\($name\\))]($style) ";
        };

        # Devenv/Direnv Integration
        direnv = {
          disabled = false;
          symbol = "📦 ";
          style = "bold green";
          format = "[$symbol$loaded/$allowed]($style) ";
          detect_files = [
            ".envrc"
            "devenv.nix"
            ".devenv"
          ];
        };

        # Docker Context
        docker_context = {
          symbol = " ";
          style = "bold blue";
          format = "[$symbol$context]($style) ";
          only_with_files = true;
          detect_files = [
            "docker-compose.yml"
            "docker-compose.yaml"
            "Dockerfile"
          ];
        };

        cmd_duration = {
          min_time = 2000;
          style = "bold yellow";
          format = "took [$duration]($style) ";
        };

        time = {
          disabled = false;
          style = "bold dimmed white";
          format = "[$time]($style) ";
          time_format = "%H:%M";
        };

        # Workflow Enhancements
        jobs = {
          symbol = "✦ ";
          style = "bold blue";
          number_threshold = 1;
          format = "[$symbol$number]($style) ";
        };

        status = {
          disabled = false;
          symbol = "✘ ";
          style = "bold red";
          format = "[$symbol$status]($style) ";
        };

        # Language Support
        python = {
          symbol = " ";
          style = "bold yellow";
          pyenv_version_name = false;
          format = "[$symbol($version)( \\($virtualenv\\))]($style) ";
        };

        nodejs = {
          symbol = " ";
          style = "bold green";
          format = "[$symbol($version)]($style) ";
        };

        rust = {
          symbol = " ";
          style = "bold #f74c00";
          format = "[$symbol($version)( \\($toolchain\\))]($style) ";
          detect_files = [
            "Cargo.toml"
            "rust-toolchain.toml"
            "rust-toolchain"
          ];
        };

        golang = {
          symbol = " ";
          style = "bold cyan";
          format = "[$symbol($version)]($style) ";
        };

        rlang = {
          symbol = "📊 ";
          style = "bold blue";
          format = "[$symbol($version)]($style) ";
        };
      };
    };
  };
}
