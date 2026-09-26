# Orca on Drgnfly

Drgnfly installs Stably AI Orca ADE for user `sinh` as `orca-ide`. The package is built from the pinned v1.4.200 source; Nix is the only installation and update authority.

## Install and launch

From the canonical NixOS repository:

```console
cd /home/sinh/git-repos/sinh-x/personal-nixos
nix build .#orca-ide
result/bin/orca-ide --version
```

Apply the Drgnfly configuration with one of the following commands. These require root access and must be run manually by the user:

```console
sudo sys test     # activate until the next boot
sudo sys rebuild  # activate persistently
```

In Niri's application launcher, search for **Orca**. The entry runs `orca-ide` and uses the packaged Orca icon. A terminal launch is also available:

```console
orca-ide
```

Do not install an upstream AppImage, DEB, or RPM and do not use Orca's self-update path. The Nix-store application is read-only and carries an externally managed package marker.

## First launch and Pi permissions

1. Launch Orca and add the repository in which you want to work.
2. Open **Settings → Agents → Agent Permissions**.
3. Select **Manual** and save the setting.
4. Confirm that Pi appears in the installed-agent picker. If it does not, open an Orca terminal and check:

   ```console
   command -v pi
   pi --version
   ```

5. Create a worktree with Orca and launch Pi from that worktree's agent picker.
6. Ask Pi to report its current working directory and confirm it is the path displayed for the Orca worktree.

Manual permissions are required. Do not add permission-bypass arguments to Pi. When testing the setting, request an operation that requires approval and verify that declining the prompt prevents the operation.

Orca owns its mutable profile. Home Manager intentionally does **not** create or overwrite `orca-data.json`; change Agent Permissions through the Orca UI.

## Native Pi worktrees versus PPA

These are separate trust paths:

- **Native Pi sessions:** launch Pi from Orca's agent picker. Pi runs inside the Orca-created worktree for isolated native work. That worktree is not, by itself, trusted PPA checkout evidence.
- **PPA requirements analysis:** launch PPA from an Orca terminal with explicit repository identity `--repo nixos`. PPA resolves the key to the registered canonical root `/home/sinh/git-repos/sinh-x/personal-nixos`. Requirements uses that canonical root for read-only analysis and records repository identity, ticket, approved full base, planned branch, and create action; it neither requires nor creates a builder checkout.
- **PPA builder execution:** after plan approval, the trusted builder launcher reserves capacity and acquires or reuses and authenticates a distinct ticket checkout. Protected runtime and registry evidence must bind that checkout to the canonical identity and exact ticket before the orchestrator materializes the linked branch or starts implementation.

Never present an arbitrary Orca-created worktree, its current directory, or objective text as authenticated PPA builder evidence. At builder launch, `PA_REPO`, the current directory, Git top level, deployment context, and registry start evidence must all equal the authenticated ticket checkout supplied by the runtime. Keep `--repo nixos` on PPA deployment commands so canonical identity remains explicit.

Before spawning an agent, use this requirements-path smoke test from an Orca terminal, including one currently inside an Orca worktree:

```console
ppa deploy requirements \
  --mode analyze \
  --repo nixos \
  --dry-run \
  --objective "Orca PPA requirements identity smoke test"
```

The command must exit successfully without spawning an agent. Record the deployment ID and verify its repository evidence:

```console
ppa registry show <deployment-id> --json
```

For requirements analysis, the evidence must name repo key `nixos` and canonical root `/home/sinh/git-repos/sinh-x/personal-nixos`, not the Orca worktree path. This check proves requirements identity only; it does not authenticate a future builder checkout.

A normal requirements launch uses the same explicit repository selection and omits `--dry-run`:

```console
ppa deploy requirements \
  --mode analyze \
  --repo nixos \
  --ticket <ticket-id> \
  --objective "<objective>"
```

Use only the approved ticket flow for builder work. Do not launch implementation against whichever Orca worktree happens to be open; the trusted builder/orchestrator launch must supply and authenticate the ticket checkout first.

## Persistence

Drgnfly enables `modules.impermanence` with `users = [ "sinh" ]`. This bind-mounts the entire `/home/sinh` from `/persist/home/sinh`, so Orca's user profile and worktrees located beneath the home directory are already persistent. No additional persistence mount is needed.

To verify persistence:

1. Create a clearly named disposable Orca workspace and worktree beneath `/home/sinh`.
2. Leave Agent Permissions set to Manual and record the workspace and worktree names.
3. Close Orca normally.
4. Reboot Drgnfly from the desktop power menu and log in as `sinh`.
5. Relaunch Orca and confirm the workspace, worktree, and Manual setting remain present.

## Updating

Orca updates are reviewed Nix changes. To update it:

1. Change the version and exact 40-character source revision in `packages/orca-ide/default.nix`.
2. Update the pinned source, pnpm dependency, and pnpm executable hashes as required.
3. Review upstream lockfile and Electron changes; do not introduce an upstream Orca application binary.
4. Build and test `.#orca-ide`, then build the Drgnfly system closure.
5. Apply the reviewed configuration with `sudo sys test` or `sudo sys rebuild` manually.

## Troubleshooting

### Orca is absent from the launcher

Confirm the profile contains the executable and desktop entry, then restart the launcher or Niri session:

```console
command -v orca-ide
ls ~/.nix-profile/share/applications/orca-ide.desktop
```

### Pi or PPA is not detected

Check both commands inside an Orca terminal, because a graphical Niri launch may see a different environment than an existing shell:

```console
command -v pi
command -v ppa
pi --version
ppa --help
ppa deploy --help
```

After changing the Home Manager profile, close all Orca windows and relaunch it from Niri.

### Wayland or Electron startup fails

Start `orca-ide` in a terminal and retain stderr and relevant journal output. Do not add broad sandbox-disable or permission-bypass flags as a workaround.

### PPA reports a repository identity error

Confirm the registered repository key and use `--repo nixos`. Do not weaken identity checks or register an Orca worktree as a replacement canonical root. For requirements analysis, verify that all runtime paths resolve to the registered canonical root. For builder execution, verify that protected launch evidence instead supplies one authenticated ticket checkout bound to that canonical identity, ticket, lease, capacity, lineage, and exact branch. A mismatch must stop before project-file or branch mutation; never substitute the currently open Orca worktree.

### State is missing after reboot

Confirm the worktree was under `/home/sinh` and inspect the existing home bind mount:

```console
findmnt /home/sinh
```

It should resolve through `/persist/home/sinh`. Do not add a second selective persistence declaration for Orca.
