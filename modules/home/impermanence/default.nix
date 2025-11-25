{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.sinh-x.impermanence;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.sinh-x.impermanence = {
    enable = mkEnableOption "Enable home-manager impermanence";
  };

  config = mkIf cfg.enable {
    imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

    home.persistence."/persist/home/${config.home.username}" = {
      directories = [
        # Development
        "git-repos"
        ".ssh"
        ".gnupg"

        # Shell history and config
        ".local/share/fish"
        ".config/fish"

        # Editors
        ".config/nvim"
        ".local/share/nvim"
        ".vscode"
        ".config/Code"

        # Desktop environment
        ".config/hypr"
        ".config/bspwm"
        ".config/sxhkd"
        ".config/polybar"
        ".config/rofi"
        ".config/dunst"
        ".config/kitty"
        ".config/alacritty"

        # Applications
        ".config/zen"
        ".mozilla"
        ".cache/mozilla"
        ".config/Signal"
        ".config/discord"
        ".config/Slack"

        # Development tools
        ".config/gcloud"
        ".docker"
        ".kube"
        ".local/share/direnv"
        ".local/share/zoxide"

        # Media and documents
        "Downloads"
        "Documents"
        "Pictures"
        "Videos"
        "Music"

        # Other app data
        ".local/share/applications"
        ".local/share/icons"
        ".local/share/keyrings"
        ".local/state"
      ];

      files = [
        ".bash_history"
        ".zsh_history"
      ];

      allowOther = true;
    };
  };
}
