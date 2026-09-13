# ii Control Center

An Android-style control-center sidebar for [Omarchy](https://omarchy.org), ported
from [illogical-impulse](https://github.com/end-4/dots-hyprland)'s (`ii`)
`sidebarRight` module. Adds a Quickshell overlay/bar-widget plugin with a
17-toggle Android quick-settings grid, calendar/to-do, world clocks, and
in-panel dialogs for wifi, bluetooth, and the audio mixer.

## Features

- **Android quick-toggle grid** — 17 toggles (wifi, bluetooth, night light,
  do-not-disturb, caffeine/keep-awake, color picker, screen snip, music
  recognition, Cloudflare WARP, and more), each with its own backend model.
  Long-press/pencil **edit mode** lets you reorder and resize tiles; the
  layout persists to
  `~/.local/state/omarchy/trevor.ii-control-center/android-toggles.json`.
- **Calendar + To-Do** — a bottom widget group with a month calendar and a
  persistent to-do list.
- **World clocks** — a configurable multi-timezone clock list.
- **In-panel dialogs**, right-click ("configure") on the relevant toggle:
  - **Wifi** — ii's own network picker (scan, connect, saved networks,
    password prompt) rendered in-shell, not an external tool.
  - **Bluetooth** — opens `blueman-manager`.
  - **Audio** — a full volume-mixer dialog (per-app streams, output/input
    device selection), ported from ii's `volumeMixer`.
  - **Night light** — toggles Omarchy's built-in night light.
- **Caffeine / keep-awake** — wired directly into Omarchy's own stay-awake
  mechanism (`~/.local/state/omarchy/indicators/stay-awake`), so the plugin's
  toggle and Omarchy's bar indicator always agree.

## Install

Copy (or symlink) this directory into your Omarchy plugins folder:

```sh
git clone https://github.com/tslove923/omarchy-ii-control-center.git \
  ~/.config/omarchy/plugins/trevor.ii-control-center
```

Then reload plugins (or run `omarchy-restart-shell`) and enable **ii Control
Center** from the plugin/bar-widget picker.

### Dependencies

Run the bundled installer once to pull in everything the toggle set and
right-click actions need (color picker, music recognition, screen snip
tools, wifi/bluetooth/audio configure targets, Cloudflare WARP, etc.):

```sh
bash ~/.config/omarchy/plugins/trevor.ii-control-center/bin/setup.sh
```

It's idempotent — safe to re-run any time — and only installs what's
missing, printing every command it runs (uses `sudo pacman` for official
packages and `yay`/`paru` for the one AUR package, `cloudflare-warp-bin`).

## Credits

UI and interaction design ported from [illogical-impulse](https://github.com/end-4/dots-hyprland)
by end-4, adapted for Omarchy's Quickshell plugin architecture.
