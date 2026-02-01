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
          "$python"
          "$nodejs"
          "$rust"
          "$golang"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
        };

        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          style = "bold cyan";
        };

        git_branch = {
          symbol = " ";
          style = "bold purple";
        };

        git_status = {
          style = "bold yellow";
          conflicted = "=";
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          untracked = "?\${count}";
          stashed = "$\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          deleted = "✘\${count}";
        };

        nix_shell = {
          symbol = " ";
          style = "bold blue";
          format = "via [$symbol$state]($style) ";
        };

        cmd_duration = {
          min_time = 2000;
          format = "took [$duration](bold yellow) ";
        };

        python = {
          symbol = " ";
          style = "bold yellow";
        };

        nodejs = {
          symbol = " ";
          style = "bold green";
        };

        rust = {
          symbol = " ";
          style = "bold orange";
        };

        golang = {
          symbol = " ";
          style = "bold cyan";
        };
      };
    };
  };
}
