# Moneydance on Drgnfly

The configuration declares Moneydance for `sinh` on **Drgnfly only**, through
`home/sinh/Drgnfly.nix`. Nix/Home Manager owns both the package and desktop entry;
it becomes available in the session only after manual activation.

## Source and runtime

- Application: **Moneydance 2024.4 (5253)** (`2024.4_5253` in nixpkgs).
- Source: the existing hash-pinned vendor archive,
  `https://infinitekind.com/stabledl/2024.4.5253/moneydance-linux.tar.gz`.
- Runtime: the locked nixpkgs OpenJDK 21 package, with matching JavaFX enabled
  by the existing Moneydance derivation. No global Java setting is changed.
- The Drgnfly-local override supplies `pkgs.openjdk21` through the derivation's
  `openjdk25` argument. The argument name is upstream's API, not the selected
  runtime version. Both terminal and desktop launch use this same overridden package.

The vendor archive bundles Java 21.0.5 and its main application classes target
Java 21. The default nixpkgs Java 25/JavaFX build failed with
`IllegalArgumentException: duplicate element: jdk.jsobject`; the local Java 21
selection avoids that dependency without changing `flake.nix` or `flake.lock`.
Nix uses its own runtime, not the vendor-bundled executable.

Do not run the vendor `.sh`/DEB installer, install a separate profile copy, or use
an in-app installer/updater. The mutable vendor `current` URL is not a source pin.
Banking, sync, extensions, real financial-data migration and licence purchase are
outside this installation's scope.

## Verification before activation

The standalone `pkgs.moneydance` output still uses Java 25; it is **not** the
Drgnfly candidate. Build the selected package and integrated home instead:

```console
package_drv=$(nix eval --raw --no-write-lock-file .#nixosConfigurations.Drgnfly.config.home-manager.users.sinh.home.packages --apply 'ps: (builtins.head (builtins.filter (p: (p.pname or "") == "moneydance") ps)).drvPath')
nix build --no-link --no-write-lock-file --max-jobs 4 --cores 2 "${package_drv}^*"
home=$(nix build --no-link --no-write-lock-file --print-out-paths --max-jobs 4 --cores 2 .#nixosConfigurations.Drgnfly.config.home-manager.users.sinh.home.path)
test -x "$home/bin/moneydance"
nix shell --no-write-lock-file .#pkgs.x86_64-linux.nixpkgs.desktop-file-utils --command desktop-file-validate "$home/share/applications/moneydance.desktop"
```

These are focused checks, not a substitute for independent repository/system
validation or graphical UAT. The independent review plan must account for the
Java 21 override rather than validate the unchanged standalone Java 25 package.
Serializing the entire desktop-entry option also currently fails on Home Manager's
removed `extraConfig` option; an amended review plan must inspect the explicit
entry fields or generated desktop file instead. Neither issue is a passing result
for the original review matrix.
Before activation, require an independently reviewed candidate, passing required
CI/system checks, and record the exact candidate SHA and reviewed matrix identity.

## Activate and launch — Sinh only

Record the current known-good system generation and confirm backup readiness.
All privileged commands below are **manual operator instructions**, never agent actions.
Use the authenticated ticket checkout, not the canonical checkout with unrelated edits:

```console
cd /home/sinh/.treehouse/personal-nixos-570358/7/personal-nixos
sudo sys test
```

Confirm this checkout still contains the exact reviewed candidate before running
`sys`; do not activate an unreviewed or subsequently changed working tree.
In a new terminal, run `command -v moneydance`, then `moneydance`.
Check that About reports **2024.4 (5253)** and close normally. Then search for
**Moneydance** in Niri's application launcher and verify the same GUI/version.
The desktop entry uses an absolute Nix-store executable, does not open a terminal,
and has Office/Finance categories. No autostart or MIME associations are added.

Skip bank connections and sync. If a licence/trial restriction blocks testing,
stop and ask; any existing entitlement is handled privately by Sinh. Do not
record keys, buy a licence, or bypass restrictions.

## Disposable-data UAT and persistence

1. Create a new uniquely named disposable dataset under `/home/sinh/Documents`;
   never open, overwrite or migrate an existing financial dataset.
2. Create an account at **0.00**, using a currency with two decimal places.
3. Add one deposit of **12.34**, memo `NX-065 disposable test`.
4. Save, close normally, reopen the same dataset and confirm the memo and exact
   balance **12.34**. Test both terminal and desktop launch paths.
5. Only after the temporary tests pass and Sinh chooses persistent activation,
   run `sudo sys rebuild` manually from the same reviewed checkout.
6. Reboot through desktop controls, log in, reopen the same dataset and verify
   the same transaction and balance **12.34**. Configuration inspection alone
   does not prove reboot persistence.

Drgnfly already persists all of `/home/sinh` from `/persist/home/sinh`; no new
mount is needed. Persistence is **not a backup** and does not protect against
file deletion or corruption. No automatic test-data cleanup is authorized.
Record the candidate SHA and actual test results without financial/private data.
Also check existing applications, terminal, launcher, browser and connectivity.

## Updates, failures and rollback

Updates are separate reviewed Nix changes, including review of the Java 21
override. Do not refresh dependencies for this installation or silently remove
the override. Rebuild and repeat affected checks/UAT after any candidate change.
On fetch/hash, Java/GTK or graphical failure, retain non-private error evidence
and stop; do not change JVM flags, channels or dependencies speculatively.

Sinh alone selects the recorded known-good system generation. **Only if the
immediately preceding generation is that known-good generation**, use
`sudo nixos-rebuild switch --rollback`; otherwise select the recorded known-good
boot generation. System rollback does not undo saved datasets or application
profile changes. Do not delete data, reset Git, or clean the checkout as rollback.
