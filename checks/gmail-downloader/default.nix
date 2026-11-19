{
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  mkHome =
    options:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit namespace; };
      modules = [
        ../../modules/home/cli-apps/gmail-downloader
        {
          home = {
            username = "sinh";
            homeDirectory = "/home/sinh";
            stateVersion = "24.11";
          };
          ${namespace}.cli-apps.gmail-downloader = options;
        }
      ];
    };
  disabled = (mkHome { }).config;
  enabled = (mkHome { enable = true; }).config;
  service = enabled.systemd.user.services.gmail-downloader;
  timer = enabled.systemd.user.timers.gmail-downloader;
  fixture = pkgs.writeScript "gmail-download-fixture" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./fixture-downloader.py}
  '';
  nonexecutable = pkgs.writeText "gmail-download-nonexecutable" "synthetic non-executable file";
  wrapperFor =
    executable:
    lib.head
      (mkHome {
        enable = true;
        inherit executable;
      }).config.systemd.user.services.gmail-downloader.Service.ExecStart;
  fixtureWrapper = wrapperFor (toString fixture);
  missingWrapper = wrapperFor "/nonexistent-gmail-schedule-fixture/gmail-download";
  nonexecutableWrapper = wrapperFor (toString nonexecutable);
  serviceFile = enabled.xdg.configFile."systemd/user/gmail-downloader.service".source;
  timerFile = enabled.xdg.configFile."systemd/user/gmail-downloader.timer".source;
in
assert !(disabled.systemd.user.services ? gmail-downloader);
assert !(disabled.systemd.user.timers ? gmail-downloader);
assert
  enabled.${namespace}.cli-apps.gmail-downloader.executable
  == "/home/sinh/git-repos/sinh-x/tools/learning-management/scripts/gmail-downloader/gmail-download";
assert builtins.length service.Service.ExecStart == 1;
assert service.Service.Type == "oneshot";
assert service.Service.UMask == "0077";
assert service.Service.TimeoutStartSec == "infinity";
assert service.Service.KillMode == "control-group";
assert service.Service.Restart == "no";
assert (service.Install.WantedBy or [ ]) == [ ];
assert
  timer.Timer == {
    OnCalendar = "*-*-* 08,12,18:00:00 Asia/Ho_Chi_Minh";
    Unit = "gmail-downloader.service";
    Persistent = true;
    AccuracySec = "1s";
    RandomizedDelaySec = 0;
  };
assert timer.Install.WantedBy == [ "timers.target" ];
pkgs.runCommand "gmail-downloader-schedule"
  {
    nativeBuildInputs = [
      pkgs.python3
      pkgs.systemd
    ];
    TZDIR = "${pkgs.tzdata}/share/zoneinfo";
    # NixOS systemd validates named zones under /etc/zoneinfo. Redirect only
    # the parser's file access to store tzdata inside the isolated build.
    calendarRedirect = "${pkgs.libredirect}/lib/libredirect.so";
  }
  ''
    cp ${./test-schedule.py} test-schedule.py
    cp ${./fixture-downloader.py} fixture-downloader.py
    python3 -B test-schedule.py \
      --wrapper ${lib.escapeShellArg fixtureWrapper} \
      --missing-wrapper ${lib.escapeShellArg missingWrapper} \
      --nonexecutable-wrapper ${lib.escapeShellArg nonexecutableWrapper}

    # Inspect the real generated files and wrapper, without running the real binary.
    mkdir -p "$out"
    cp ${serviceFile} "$out/gmail-downloader.service"
    cp ${timerFile} "$out/gmail-downloader.timer"
    cp ${lib.head service.Service.ExecStart} "$out/scheduled-wrapper"
    python3 - <<'PY'
    import os
    from pathlib import Path
    import subprocess

    output = Path(os.environ["out"])
    sentinel = "SYNTHETIC-PRIVATE-CONTENT-DO-NOT-EXPORT"
    for path in output.iterdir():
        assert sentinel not in path.read_text(), path.name
    calendar = "*-*-* 08,12,18:00:00 Asia/Ho_Chi_Minh"
    expected = [
        "2026-11-19 01:00:00", "2026-11-19 05:00:00", "2026-11-19 11:00:00",
        "2026-11-20 01:00:00", "2026-11-20 05:00:00", "2026-11-20 11:00:00",
    ]
    for zone in ("UTC", "America/New_York"):
        result = subprocess.run(
            ["systemd-analyze", "calendar", "--iterations=6", "--base-time=2026-11-19 00:00:00 UTC", calendar],
            env={**os.environ, "TZ": zone,
                 "LD_PRELOAD": os.environ["calendarRedirect"],
                 "NIX_REDIRECTS": "/etc/zoneinfo=" + os.environ["TZDIR"]},
            capture_output=True, text=True,
        )
        assert result.returncode == 0, result.stderr
        # With host TZ=UTC, systemd prints UTC directly, not a second line.
        utc_lines = [line for line in result.stdout.splitlines() if line.rstrip().endswith(" UTC")]
        assert len(utc_lines) == 6, result.stdout
        assert all(stamp in line for stamp, line in zip(expected, utc_lines)), result.stdout
        (output / ("calendar-" + zone.replace("/", "-") + ".log")).write_text(result.stdout)
    PY
  ''
