#!/bin/bash
# setup.sh — ensure every dependency the ii Control Center's full Android
# toggle set + right-click actions need is present. Idempotent: checks what's
# already installed (`command -v` / `pacman -Q` first) and only installs what
# is missing, so it is safe to re-run any time (e.g. after a clean install).
#
# Where each dependency was sourced from (per the plugin's conventions):
#   hyprpicker, songrec, upower, hypridle, swappy, slurp, grim, wl-clipboard
#     -> illogical-impulse's own install tree (sdata/deps-info.md +
#        sdata/dist-arch/illogical-impulse-{widgets,screencapture,toolkit}/PKGBUILD).
#   nm-connection-editor (wifi "configure"), blueman (bluetooth "configure"),
#   pavucontrol-qt (audio "configure") -> sdata/dist-arch/illogical-impulse-{kde,audio}/PKGBUILD
#        (ii ships kcmshell6/plasma-nm + pavucontrol-qt for the same purposes;
#        this plugin opens the equivalent standalone tools instead).
#   cloudflare-warp-bin (AUR) -> the CloudflareWarp toggle shells to `warp-cli`;
#        not in ii's PKGBUILDs, needs the AUR package.
#
# NOTE: `sudo` is used for package installation (Omarchy is Arch-based; the
# user owns the machine). The script prints exactly what it runs.

set -euo pipefail

# Packages from the official (extra) repositories — all the toggle/action
# backends except Cloudflare WARP live here.
EXTRA_PKGS=(
  hyprpicker      # color picker toggle ("hyprpicker -a")  [illogical-impulse-widgets]
  songrec         # music recognition toggle               [illogical-impulse-widgets]
  upower          # power-profile toggle (Quickshell.Services.UPower) [illogical-impulse-toolkit]
  hypridle        # keep-awake efficacy (honors idle_inhibit)         [illogical-impulse-toolkit]
  swappy          # screen-snip edit/annotation             [illogical-impulse-screencapture]
  slurp           # screen-snip region selection           [illogical-impulse-screencapture]
  grim            # screen-snip capture                    [illogical-impulse-screencapture]
  wl-clipboard    # screen-snip -> clipboard                [illogical-impulse-basic]
  nm-connection-editor  # wifi "configure" action          [illogical-impulse-kde]
  blueman               # bluetooth "configure" action     [illogical-impulse-kde]
  pavucontrol-qt        # audio "configure" action         [illogical-impulse-audio]
)

missing=()
for pkg in "${EXTRA_PKGS[@]}"; do
  if ! pacman -Q "$pkg" >/dev/null 2>&1; then
    missing+=("$pkg")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Installing missing packages: ${missing[*]}"
  sudo pacman --needed -S --noconfirm "${missing[@]}"
else
  echo "All official-repo dependencies already installed."
fi

# Cloudflare WARP — AUR package `cloudflare-warp-bin` (provides `warp-cli`).
if ! command -v warp-cli >/dev/null 2>&1; then
  echo "warp-cli not found — installing AUR package cloudflare-warp-bin."
  if command -v yay >/dev/null 2>&1; then
    yay -S --needed cloudflare-warp-bin
  elif command -v paru >/dev/null 2>&1; then
    paru -S --needed cloudflare-warp-bin
  else
    echo "No AUR helper (yay/paru) found. Install 'cloudflare-warp-bin' manually:" >&2
    echo "  git clone https://aur.archlinux.org/cloudflare-warp-bin" >&2
    exit 1
  fi
else
  echo "cloudflare-warp already installed (warp-cli present)."
fi

echo
echo "Setup complete. All ii Control Center toggle/action dependencies are present."
