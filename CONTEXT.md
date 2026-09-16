# CONTEXT

Why this flake looks the way it does. Options and binds are documented in
[README.md](./README.md).

## DMS's binds win over ours

On DMS hosts, `config.kdl` belongs to DMS. It includes `hm.kdl` (what this flake
renders) first, then `dms/binds.kdl` and the other `dms/*.kdl` files. niri lets
a later `binds` block override the same key from an earlier one, so any key DMS
binds is silently lost here.

DMS binds `Mod+M` to its process list. That is why the scratchpad binds moved
from `Mod+M` to `Mod+X` / `Mod+Shift+X` / `Mod+Ctrl+X`, the same keys the
Hyprland flake uses for minimize. Check `~/.config/niri/dms/binds.kdl` before
picking a new key.

## Scratchpads

niri-scratchpad moves stashed windows to a workspace it finds by the hardcoded
name `stash`, and skips stashing when that workspace is missing. The old
`workspaces.statch.name = "Scratchpad"` rendered `workspace "Scratchpad"`, so
windows were never stashed. The workspace is visible in bars; upstream's
hidden-workspace variant depends on a draft niri PR.

`create` starts the register daemon itself on first use, so nothing has to run
at startup.

niri's `spawn` takes argv, not a command line. `spawn "niri-scratchpad create 1"`
looks for a binary literally named that and fails without a message. Pass each
argument separately, or use `spawn "sh" "-c" "…"` when you need a shell.

## Launcher entries for unset apps

`terminal`, `browser`, `editor`, `fileManager` and `passwordManager` can all
resolve to null. Interpolating null into a string fails evaluation, so the
`Mod+A` menu filters those entries out instead of showing broken ones.

## Screenshots

- **Screenshot portal goes to wlr.** niri's gnome-portal screenshot path
  asserts a single output and errors on multi-monitor (niri-wm/niri#117).
  Flameshot 14 dropped grim and captures through
  `org.freedesktop.portal.Screenshot`, so on those hosts it got nothing.
  `default.nix` routes only the Screenshot interface to the grim-based wlr
  backend; ScreenCast stays on gnome.
- **Native niri shots skip `wl-copy`.** `niri msg action screenshot-screen` /
  `screenshot-window` already put the image on the clipboard, and they write
  the file from a background thread after the command returns. Reading the
  file right away with `wl-copy < "$FILE"` races that write and, under
  `set -e`, fails whenever the file is not there yet. Only the grim scopes copy
  by hand.
- **Satty grabs the whole focused monitor first**, then crops live. The region
  stays adjustable while you annotate, which selecting with slurp first would
  not allow.
- **Flameshot's overlay is matched by title.** It is a normal toplevel with an
  empty app-id. It and satty's editor open floating and fullscreen, so they
  overlay the layout instead of becoming tiles.

## Screen recording

- **No window recording.** niri's IPC `Window` has no geometry: `layout` only
  has tile sizes and a position inside the workspace view, and tiled windows
  have no fixed on-screen rectangle at all. Region (`r`) covers the use case.
- **`a` records the focused output.** wl-screenrec with neither `-o` nor `-g`
  exits with "multiple enabled displays … bailing" on multi-monitor hosts.
- **`m` filters on `.logical != null`.** `niri msg -j outputs` is an object
  keyed by output name, and disabled outputs are included with
  `logical: null`. wl-screenrec cannot record those.
- **Saved vs failed** comes from wl-screenrec's exit status (`mkRecordCmd` in
  the lib subflake). wl-screenrec catches SIGINT/SIGTERM/SIGHUP and exits 0, so
  stopping with `q` (`pkill -INT`) reports "saved".
- **A cancelled picker records nothing.** Cancelling wofi or slurp leaves an
  empty flag value. wl-screenrec treats `-o ""` as no `-o` and records the
  only output on a single-monitor host, and `-g ""` fails after "Recording
  started" has already shown. `mkRecordCmd` evaluates the flags once with
  `set --` and exits when any of them is empty, so callers need no guard.

## The flake check

The check evaluates the module but never builds it: it writes the toplevel's
`drvPath` into a text file. `unsafeDiscardOutputDependency` keeps that `.drv`
path from pulling in the whole system build. home-manager is pinned to a
commit because a branch tarball's sha256 changes on the next push.
`useGlobalPkgs` matches the hosts.
