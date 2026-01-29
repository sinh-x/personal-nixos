{
  lib,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.impermanence;
in
{
  # Note: home-manager impermanence module is automatically imported by the NixOS module
  # See: https://github.com/nix-community/impermanence?tab=readme-ov-file#home-manager

  options.${namespace}.impermanence = {
    enable = mkEnableOption "home-manager impermanence";

    persistPath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Base path for home persistence (module adds /home/<username> automatically)";
    };
  };

  config = mkIf cfg.enable {
    # Note: username is automatically appended to persistPath by the module
    home.persistence."${cfg.persistPath}" = {
      directories = [
        # === CRITICAL - Security & Auth ===
        ".ssh"
        ".gnupg"
        ".config/sops/age"

        # === User Data Folders ===
        "Documents"
        "Pictures"
        "Videos"
        "Music"

        # === Shell & CLI ===
        ".local/share/fish"
        ".local/share/zoxide"
        ".config/atuin"
        ".local/share/atuin"

        # === Development ===
        "git-repos"
        ".cargo"
        ".rustup"
        ".npm"
        ".local/share/nvim"
        ".config/gh"
        ".config/git"
        ".docker"

        # === Devenv & Direnv ===
        ".devenv"
        ".local/share/direnv"
        ".config/direnv"

        # === Browsers ===
        ".mozilla/firefox"
        ".zen"
        ".config/zen"
        ".config/BraveSoftware"
        ".config/google-chrome"

        # === Password Manager ===
        ".config/Bitwarden"

        # === Cloud & Auth ===
        ".config/gcloud"

        # === Input Method ===
        ".config/fcitx5"
        ".local/share/fcitx5"

        # === Chat Applications ===
        ".config/discord"
        ".config/Slack"
        ".config/gurk"
        ".local/share/gurk"
        ".local/share/TelegramDesktop"

        # === Applications ===
        ".config/Code"
        ".config/spotify"
        ".config/superProductivity"
        ".config/obsidian"
        ".config/syncthing"
        ".config/Signal"
        ".local/share/activitywatch"
        ".steam"
        ".local/share/Steam"
        ".local/share/mpd"

        # === Desktop ===
        ".config/hypr"
        ".local/share/applications"
        ".local/share/icons"
        ".local/share/hyprland"

        # === Misc state ===
        ".local/state"

        # === Project-specific ===
        ".config/sinh-x-scripts"
      ];

      files = [
        ".config/monitors.xml"
      ];
    };
  };
}
