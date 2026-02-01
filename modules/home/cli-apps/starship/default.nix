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
          "$git_branch"
          "$git_status"
          "$nix_shell"
          "$direnv"
          "$python"
          "$nodejs"
          "$rust"
          "$golang"
          "$rlang"
          "$jobs"
          "$status"
          "$cmd_duration"
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

        git_branch = {
          symbol = " ";
          style = "bold purple";
          format = "[$symbol$branch(:$remote_branch)]($style) ";
        };

        git_status = {
          style = "bold yellow";
          format = "([$all_status$ahead_behind]($style) )";
          conflicted = "=\${count}";
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          untracked = "?\${count}";
          stashed = "\\$\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          renamed = "»\${count}";
          deleted = "✘\${count}";
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

        cmd_duration = {
          min_time = 2000;
          style = "bold yellow";
          format = "took [$duration]($style) ";
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
          pyenv_version_name = true;
          format = "[\${symbol}(\${version})( \\(\$virtualenv\\))]($style) ";
        };

        nodejs = {
          symbol = " ";
          style = "bold green";
          format = "[$symbol($version)]($style) ";
        };

        rust = {
          symbol = " ";
          style = "bold #f74c00";
          format = "[$symbol($version)]($style) ";
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
