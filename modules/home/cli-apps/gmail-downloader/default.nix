{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.cli-apps.gmail-downloader;
  runner = pkgs.writeShellApplication {
    name = "gmail-downloader-scheduled";
    text = ''
      # systemd stops the entire control group, including the foreground child.
      trap 'exit 143' TERM
      trap 'exit 130' INT
      umask 077

      executable=${lib.escapeShellArg cfg.executable}
      if [[ ! -f "$executable" || ! -x "$executable" ]]; then
        printf '%s\n' 'gmail-downloader: external executable missing or not executable' >&2
        exit 1
      fi

      result=0
      for profile in personal andafin; do
        if "$executable" download --root /home/sinh/.local/share/gmail-downloader --profile "$profile"; then
          printf '%s: download succeeded\n' "$profile"
        else
          code=$?
          printf '%s: download failed (exit %s)\n' "$profile" "$code" >&2
          # Cancellation is not an ordinary account failure. Never start another
          # profile after a signalled child, even if only the child was signalled.
          if (( code >= 128 )); then
            exit "$code"
          fi
          result=1
        fi
      done
      exit "$result"
    '';
  };
in
{
  options.${namespace}.cli-apps.gmail-downloader = {
    enable = lib.mkEnableOption "login-only read-only Gmail downloads";
    executable = lib.mkOption {
      type = lib.types.strMatching "/.*";
      default = "/home/sinh/git-repos/sinh-x/tools/learning-management/scripts/gmail-downloader/gmail-download";
      description = ''
        Absolute runtime path to the operator-managed learning-management executable.
        This string does not import the local checkout, credentials or archive into
        the Nix store. NX builds only the scheduling wrapper, not the downloader.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.gmail-downloader = {
      Unit.Description = "Read-only Gmail downloads for personal and andafin";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe runner;
        UMask = "0077";
        TimeoutStartSec = "infinity";
        KillMode = "control-group";
        Restart = "no";
      };
    };

    systemd.user.timers.gmail-downloader = {
      Unit.Description = "Download Gmail at 08:00, 12:00 and 18:00 Vietnam time";
      Timer = {
        OnCalendar = "*-*-* 08,12,18:00:00 Asia/Ho_Chi_Minh";
        Unit = "gmail-downloader.service";
        Persistent = true;
        AccuracySec = "1s";
        RandomizedDelaySec = 0;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
