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
