# Neon CLI on Drgnfly

Sinh’s Drgnfly Home Manager profile includes the official Neon CLI once for use across projects. This setup provides the CLI only. It does not authenticate, provision resources, change a database, or configure Pi/PPA, skills or MCP.

## Package and pin

`home/sinh/Drgnfly.nix` selects `pkgs.neon-cli`, discovered from `packages/neon-cli/default.nix`. The Nix package name deliberately differs from nixpkgs’ unrelated `neon` HTTP/WebDAV library; the executable is `neon`.

The package pins upstream **Neon CLI 9.9.3**, release `neon@9.9.3`, asset `neon-linux-x64`:

- [Official installation documentation](https://neon.com/docs/cli/install)
- [Exact release](https://github.com/neondatabase/neon-pkgs/releases/tag/neon%409.9.3)
- SHA-256: `5ed0502c649898d6fcbd8c86f0cd762cac9f682a8a5dd00e0356b7530dfdd345`

This is the official standalone x86_64 Linux binary with bundled Node 22, not an upstream source build. It needs no global npm installation or project Node version. Nix’s `buildFHSEnv` wrapper supplies the Linux loader and GCC runtime without changing the binary: ELF patching would invalidate its embedded JavaScript offsets. Running it requires Bubblewrap/user namespaces, provided by the Nix runtime closure on Drgnfly. The release hash fixes the downloaded bytes. Upstream’s npm CLI requires Node 20.19 or newer, but a separate host Node installation is not used by this package.

To update, review a specific official release and its runtime, change only this derivation’s version and verified asset hash, then rebuild and repeat the local checks. Do not use `latest`, `npm install -g`, or refresh all flake inputs to update this package.

## Build and activation

Once the new package file is included in the flake’s source, a nonprivileged package build is:

```sh
nix build --no-link --no-update-lock-file .#neon-cli
```

Run the retained smoke test against the built output:

```sh
package=$(nix build --no-link --print-out-paths --no-update-lock-file .#neon-cli)
bash packages/neon-cli/smoke-test.sh "$package" 9.9.3
```

This runs `--version` and `--help` in two disposable project directories with an empty environment, isolated home and no network. It does not sign in or mount host credentials. It runs outside the Nix build sandbox because the FHS runtime itself needs user namespaces. These fixtures are not fresh installed-profile terminals.

System activation is separate and must be performed manually by Sinh, not an agent. Follow the repository’s normal configuration review/build procedure first, especially if unrelated changes are present. The operator-only activation command is:

```sh
sudo sys rebuild
```

This activates the whole current configuration, not just Neon. Do not run it until the other pending changes are also ready.

## Local acceptance after activation

Open a fresh ordinary terminal in each of two different projects selected by Sinh, outside project-specific development shells. In each terminal run:

```sh
command -v neon
readlink -f "$(command -v neon)"
neon --version
neon --help
```

Both terminals must resolve the same Nix-managed executable, report `9.9.3`, and show Neon command help including projects and branches. Neither command needs login. If a project-local binary, alias or custom PATH shadows it, report the mismatch rather than modifying the project to hide it. An existing development shell may intentionally use a different PATH; retest from an ordinary terminal.

Package/fixture checks are not evidence that the activated user profile works in two real projects. Installed-terminal acceptance remains pending until Sinh observes it. Authentication is untested and reserved to a separately authorized operator session. Do not run bare `neon`, `neon login`, account/API commands or database commands as part of these local checks.

## Scoped rollback

Remove only the `neon-cli` entry from `home/sinh/Drgnfly.nix`. Remove `packages/neon-cli/default.nix` only if nothing else references the package. Review the resulting diff and let Sinh rebuild manually. Do not reset files, refresh the lock, uninstall unrelated packages, delete Neon private state, or roll back a whole generation containing unrelated changes. No database or cloud rollback is needed because this setup performs no such operations.
