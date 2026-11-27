# Drgnfly Umbriel + Noctalia trial (NX-077)

This trial is optional. Niri remains the initial autologin and production fallback.
Do not activate an incomplete or failed candidate. Builds and source translation
are not human acceptance, independent review or production promotion.

## Baseline and scope

Implementation starts in the selected ticket worktree on
`feature/NX-077-umbriel-noctalia-trial`, base
`7527a4413bba6de26c761cec5905e772f078cfe0`. The approved analysis is
`d-725020-NX-077-analysis`, content revision 1, SHA-256
`3129fff9f91189d132af4cf389e7cbfdff9b37515a2fe0a5aa02bfee3abd541e`.
The selected base adds the committed PA-server integration to the analysis's
`31c03a9` baseline. Preserve that integration and existing lock nodes. Do not copy
uncommitted state from the canonical checkout.

The source baseline is 112 shortcut triggers, 17 window-rule blocks and eight
named workspaces. Its template and shared extras are unchanged from analysis:

- `modules/home/wm/niri/niri_config/config.kdl`: SHA-256
  `e928ee2929aa8078e574445ed69be55a4bdb86ed03ce93978780ba145bc29e65`.
- `home/sinh/niri-extras.nix`: SHA-256
  `4b65b9c99c6f10b3e2db159a719f4d616c4759e8d0debce133c042bf05dd6a1c`.
- Initial committed `flake.lock`: SHA-256
  `f3a342df7f5b6288d72c51dcb25c863b8acb2e5f0090442fa62b4560903a1d5d`.

Installed-KDL equality remains unverified; do not bypass the earlier denied read.
Secret Service ownership is observable, but does not prove that a collection is
unlocked or that Noctalia history persists. Never export secrets, add a credential
store without direction, use plaintext keys or migrate Niri's cliphist silently.

## Session isolation

The trial options are `modules.wm.umbriel.enable` (NixOS) and
`sinh-x.wm.umbriel.enable` (Home Manager). Both default to false. Keep host enables
off until the translated configuration, capture/power safety paths and P4 checks
are complete; phase commits alone are not permission to activate upstream defaults.
The source fixture enables a synthetic configuration only to inspect declarations.

When enabled, the greeter boundary calls the documented `niri-session` and
`start-umbriel` launchers, rather than starting the compositor binary directly.
It serializes transitions in the private user runtime directory, refuses an active
or starting compositor, and stops stale portal backends only at the inactive
session boundary. The selected launcher imports the fresh identity and supplies
compositor readiness. Logout/failure cleans the selected service/target and stale
activation environment; no in-session blanket portal restart is used as a repair.

Noctalia and the trial Fcitx5 client follow `umbriel-session.target` and bind to
`umbriel.service`. The existing host Fcitx5 package, Lotus server, Secret Service,
Polkit and authentication policy remain in use. Niri retains its old shell stack.
A repository-owned `niri-session.target` binds its legacy screenshot watcher to
Niri: upstream Niri v26.04 does not provide that target. The global Home Manager
session target is not changed. Operator UI overrides or independently started
services can still conflict and must be qualified during the real session trial.

The pinned public [installation manual](https://github.com/noctalia-dev/umbriel/blob/b56b66ce66b4cf84d34e522d3ad63a82b215ccd9/docs/user/installation.md)
and [configuration manual](https://github.com/noctalia-dev/umbriel/blob/b56b66ce66b4cf84d34e522d3ad63a82b215ccd9/docs/user/configuration.md)
document these public launcher/readiness/configuration APIs. They are independent
sources, not a workaround to retrieve previously denied upstream files. That
source-access incident remains unresolved; do not retry those coordinates without
owner-qualified access. Live lifecycle and portal round-trip UAT remain mandatory.

## Qualification and recovery

Only Drgnfly may enable the trial. Preserve the Niri bridge patch and other hosts.
Before operator activation, require scoped configuration/parser/fixture checks
and a non-activating Drgnfly build on the exact candidate. Keep failures visible.
Sinh alone performs privileged system activation and real capture/sharing,
Vietnamese input, mixed-DPI/hotplug, clipboard persistence, Zoom, lock and
hibernate/resume qualification. No live private content capture is authorized.

A failed trial must retain the Niri greeter entry. Log out and select Niri first.
If the greeter is unusable, Sinh selects the previous known-good NixOS generation
from the boot menu. Do not remove previous generations while testing. No automatic
promotion, merge, push or worktree retirement follows from a successful build.

Current implementation progress, check evidence and phase commits are recorded in
the producing deployment's primary HTML report, not in this maintained guide.
