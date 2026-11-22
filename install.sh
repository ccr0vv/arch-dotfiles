#!/usr/bin/env bash
set -Eeuo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
repo=$PWD
mode=default; dry=0
for arg in "$@"; do
 case $arg in --default|--full|--custom) mode=${arg#--};; --dry-run) dry=1;; *) echo "Unknown option: $arg" >&2; exit 2;; esac
done
run() { printf '+ '; printf '%q ' "$@"; printf '\n'; if (( ! dry )); then "$@"; fi; }
ask() { local response; read -r -p "$1 [y/N] " response; [[ $response =~ ^[Yy]$ ]]; }
readlist() { grep -vE '^([[:space:]]*#|[[:space:]]*$)' "$repo/packages/$1.txt"; }
mapfile -t official < <(readlist desktop; readlist default)
mapfile -t aur < <(readlist default-aur)
for group in optional optional-aur; do
 while IFS= read -r pkg; do
  if [[ $mode == full ]] || { [[ $mode == custom ]] && ask "Install $pkg?"; }; then
   if [[ $group == optional ]]; then official+=("$pkg"); else aur+=("$pkg"); fi
  fi
 done < <(readlist "$group")
done
model=$(cat /sys/class/dmi/id/product_version 2>/dev/null || true)
thinkpad=0
if [[ $model == 'ThinkPad X390' ]]; then
 thinkpad=1; mapfile -t hw < <(readlist thinkpad); official+=("${hw[@]}"); mapfile -t hw < <(readlist thinkpad-aur); aur+=("${hw[@]}")
fi
if (( ! dry )); then
 [[ $EUID != 0 ]] || { echo 'Run as your normal user, not root.'; exit 1; }
 [[ -r /etc/arch-release ]] || { echo 'Arch Linux required.'; exit 1; }
 command -v sudo >/dev/null
fi
if [[ " ${official[*]} " == *" steam "* ]] && { ! command -v pacman-conf >/dev/null || ! pacman-conf --repo-list | grep -qx multilib; }; then
 echo 'Steam skipped: enable multilib separately if desired.'
 filtered=(); for pkg in "${official[@]}"; do [[ $pkg == steam ]] || filtered+=("$pkg"); done; official=("${filtered[@]}")
fi
printf 'Mode: %s | ThinkPad X390: %s\n' "$mode" "$thinkpad"
printf 'Official: %s\n' "${official[*]}"; printf 'AUR candidates: %s\n' "${aur[*]}"; echo "Also: Proton VPN (repository or AUR), Paru bootstrap, theme prompt."
if (( dry )); then echo 'Dry run: no filesystem, package or service changes.'; exit 0; fi
ask 'Upgrade Arch and install selected packages?' || exit 0
sudo -v
stamp=$(date +%Y%m%d-%H%M%S)-$$
backup="$HOME/.local/state/arch-dotfiles/backups/$stamp"
mkdir -p "$backup"
exec > >(tee -a "$backup/install.log") 2>&1
trap 'echo "Installation failed at line $LINENO; see $backup/install.log" >&2' ERR
sudo pacman -Syu --needed "${official[@]}"
if ! command -v paru >/dev/null; then
 tmp=$(mktemp -d); git clone https://aur.archlinux.org/paru.git "$tmp/paru"; (cd "$tmp/paru" && makepkg -si); rm -rf "$tmp"
fi
for pkg in "${aur[@]}"; do
 if pacman -Si "$pkg" >/dev/null 2>&1; then sudo pacman -S --needed "$pkg"; else paru -S --needed "$pkg"; fi
done
if pacman -Si proton-vpn-gtk-app >/dev/null 2>&1; then sudo pacman -S --needed proton-vpn-gtk-app; else paru -S --needed proton-vpn-gtk-app; fi
while IFS= read -r -d '' src; do
 rel=${src#"$repo/dotfiles/"}; dest="$HOME/$rel"
 if [[ $rel == .config/nvim/* ]] && ! command -v nvim >/dev/null; then continue; fi
 if [[ -e $dest || -L $dest ]]; then mkdir -p "$backup/$(dirname "$rel")"; cp -a -- "$dest" "$backup/$rel"; fi
 mkdir -p "$(dirname "$dest")"; cp --remove-destination -p -- "$src" "$dest"
done < <(find "$repo/dotfiles" -type f -print0)
mkdir -p "$HOME/Pictures/Screenshots" "$HOME/.config/mako"
wal --theme "$HOME/.config/wal/colorschemes/dark/dark.json" -n -s -t
if [[ -e "$HOME/.config/mako/config" ]]; then mkdir -p "$backup/.config/mako"; cp -a "$HOME/.config/mako/config" "$backup/.config/mako/config"; fi
cp "$HOME/.cache/wal/colors-mako" "$HOME/.config/mako/config"
rootbackup=/var/backups/arch-dotfiles/$stamp
rootcopy() { local rel=$1; if sudo test -e "/$rel"; then sudo mkdir -p "$rootbackup/$(dirname "$rel")"; sudo cp -a "/$rel" "$rootbackup/$rel"; fi; sudo install -D -m 644 "$repo/system/$rel" "/$rel"; }
rootcopy etc/systemd/zram-generator.conf
if (( thinkpad )); then
 rootcopy etc/thinkfan.conf; rootcopy etc/modprobe.d/thinkpad_acpi.conf; rootcopy etc/modprobe.d/nobeep.conf
 rootcopy etc/systemd/system/battery-threshold.service
 sudo systemctl daemon-reload; sudo systemctl enable battery-threshold.service
fi
if ask 'Install pinned SilentSDDM theme (activation remains manual)?'; then
 tmp=$(mktemp -d); git clone https://github.com/uiriansan/SilentSDDM.git "$tmp/silent"
 git -C "$tmp/silent" checkout --detach 8ecdd84438ada68ce4ee7ce70522d4484b103477
 if sudo test -e /usr/share/sddm/themes/silent; then sudo mkdir -p "$rootbackup"; sudo cp -a /usr/share/sddm/themes/silent "$rootbackup/silent"; fi
 sudo mkdir -p /usr/share/sddm/themes/silent
 sudo rsync -a --exclude=.git "$tmp/silent/" /usr/share/sddm/themes/silent/
 sudo mkdir -p /usr/share/fonts/silent
 sudo cp -a "$tmp/silent/fonts/." /usr/share/fonts/silent/
 sudo fc-cache -f
 rootcopy etc/sddm.conf; rm -rf "$tmp"
fi
sudo systemctl enable NetworkManager.service bluetooth.service tuned.service tuned-ppd.service
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service syncthing.service
if command -v cupsd >/dev/null && [[ " ${official[*]} " == *" cups "* ]]; then sudo systemctl enable cups.socket; fi
printf 'Finished. Backups: %s\nReview README before rebooting.\n' "$backup"
