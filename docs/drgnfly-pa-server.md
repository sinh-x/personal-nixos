# Drgnfly PA server

Drgnfly imports the locked PA platform's opt-in NixOS module and enables
`services.pa-server` in its [host configuration](../systems/x86_64-linux/Drgnfly/default.nix).
It starts the Agent API at boot, without an interactive login, as the existing
unprivileged `sinh` account on **127.0.0.1:9848**. This is a system service, not a
Home Manager/user service.

The upstream contract is `docs/nixos-pa-server.md` in the `pa-platform` input
(declared in [flake.nix](../flake.nix)). That document owns the module's options
and supervision behavior; this page covers Drgnfly's integration and operator
checks. Source configuration alone does not prove activation or boot recovery.

## Host integration

- `package = pkgs.pa-platform` selects the same customized bundle installed by
  [Drgnfly's home configuration](../home/sinh/Drgnfly.nix), preserving the
  [overlay's feature choices](../overlays/sinh-x/default.nix).
- The upstream default port is retained. No firewall opening, CORS, proxy, or
  externally reachable bind address is added. Loopback is accessible to other
  local processes; it is not per-user isolation.
- `HOME` and the working directory are `/home/sinh`. The upstream unit's
  `RequiresMountsFor` waits for that home's existing persistent bind mount, which
  depends on `/persist`. No new data directory, migration, ownership change, or
  secret is introduced.
- PA's default configuration, runtime data, and shared usage roots remain
  `~/.config/sinh-x/pa-platform`, `~/.local/share/pa-platform`, and
  `~/Documents/ai-usage`. The service does not inherit interactive shell
  environment variables, profile PATH, or login-session credentials. If the
  operator uses different PA paths or needs additional runtime tools or
  credentials, resolve those explicitly before activation; never put credential
  values in Nix expressions or the world-readable store.

## Before activation

Follow [repository safety](agents/safety.md): agents never run privileged
commands. **Sinh runs the activation and service-control commands below.**

From `/home/sinh/git-repos/sinh-x/personal-nixos`, inspect any existing server:

```sh
systemctl status pa-server.service --no-pager
systemctl --user status pa-server.service --no-pager
ss -ltnp '( sport = :9848 )'
readlink -f /run/current-system
readlink -f /nix/var/nix/profiles/system
```

An absent unit is expected before the first activation. Confirm whether a manual,
background, or user-service server already owns the configured port or PA data
root, even if it uses a different port. Resolve it through its confirmed owner
before switching to the system service. Do not delete PID files, force takeover,
or use `pa-core serve status` as an observational check: upstream documents that
it can clean up stale PID state. Preserve existing PA data and the known-good
system generation; do not edit databases or credential files for this setup.

A focused, non-activating validation of the generated unit is:

```sh
nix eval --raw --no-write-lock-file \
  .#nixosConfigurations.Drgnfly.config.system.build.toplevel.drvPath
nix build --no-link --no-write-lock-file \
  '.#nixosConfigurations.Drgnfly.config.systemd.units."pa-server.service".unit'
```

These checks do not build the complete system, launch the server, or validate
provider credentials and deployment execution. A complete system build can be
performed separately before activation if required by the current change plan.

## Sinh-only activation and smoke test

After reviewing the candidate and resolving any existing-server conflict:

```sh
sudo sys test
systemctl status pa-server.service --no-pager
systemctl show pa-server.service -p User -p ExecStart -p MainPID
ss -ltnp '( sport = :9848 )'
curl --fail --silent --show-error http://127.0.0.1:9848/api/health
journalctl -u pa-server.service -b --no-pager -n 50
```

Confirm that the selected user is `sinh`, the socket is only on `127.0.0.1:9848`,
the health endpoint succeeds, and the journal has no permission, PID-ownership,
package, or port errors. Redact sensitive information before sharing output.
Health is not proof that agent runtimes or authenticated deployment execution
work; those require their own authorized checks.

After successful temporary activation, test process supervision as the operator:

```sh
sudo systemctl restart pa-server.service
systemctl status pa-server.service --no-pager
curl --fail --silent --show-error http://127.0.0.1:9848/api/health
sudo systemctl stop pa-server.service
systemctl is-active pa-server.service
ss -ltn '( sport = :9848 )'
sudo systemctl start pa-server.service
curl --fail --silent --show-error http://127.0.0.1:9848/api/health
```

The stopped state should be inactive with no service-owned listener. Recheck the
journal after restart/start. After smoke tests pass and Sinh approves persistence:

```sh
sudo sys rebuild
systemctl is-enabled pa-server.service
```

At the next authorized reboot, check status, loopback socket, health, and the
current boot's journal again. Boot-time startup without interactive login remains
unverified until that observation. Do not use `systemctl --user` or
`pa-core serve stop` to control the system service.

## Recovery and rollback

If startup fails, diagnose the journal and verified account/home access,
package, port, and data-root ownership before retrying. Correct the actual cause
rather than deleting PID files or using `--force`. If systemd rate-limits repeated
failures, only after correction may Sinh run:

```sh
sudo systemctl reset-failed pa-server.service
sudo systemctl start pa-server.service
```

To remove automatic startup, set `services.pa-server.enable = false` in the host
configuration and have Sinh apply the configuration. This preserves PA data and
does not recreate an earlier manual or user service. Editing source alone does
not stop an active unit. If temporary activation damages system operation, Sinh
can reboot into the recorded known-good boot generation; verify the selected
entry rather than assuming it is the immediately preceding generation. System
rollback does not undo application-data changes. Keep unrelated lock-file edits
and other operator-owned changes intact.
