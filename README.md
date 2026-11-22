# Arch dotfiles — ThinkPad X390

First candidate release. Targets an already installed Arch Linux with a normal sudo-capable user, working internet, and a bootable kernel. Does not partition disks, install a bootloader, or touch Windows.

```sh
bash install.sh --default --dry-run
bash install.sh --custom --dry-run
bash install.sh --default
```

`--full` selects optional packages too, except manual extras and Steam when multilib is unavailable. `--custom` prompts per optional package. AUR packages require review and may fail as repositories evolve. The installer performs a full system upgrade, backs up replaced files, and does not reboot. Test in a VM first.

## Notes
- Hyprland Lua is the active configuration (0.57). The supplied legacy conf is not deployed. Monitor mode is preferred, external displays are independent. Clipboard history references were removed because cliphist was absent.
- SilentSDDM is pinned to the supplied commit. Test it before enabling SDDM; installer deliberately leaves SDDM activation manual.
- Battery threshold and Thinkfan are hardware-specific. Fan service is not enabled automatically; validate sensors first. Legacy battery guard is deliberately not deployed because of unsafe idle and suspend logic.
- Timeshift is installed but snapshots are not configured automatically; use its setup wizard. No bootloader changes.
- Proton VPN is resolved from the configured repositories; if unavailable, install the official client manually. DroidCam is manual; no unverified binary is bundled.
- Personal images and the Persona 5 sound are excluded from the public archive. Restore them privately from the original backup if desired. No license is asserted for third-party configs or assets. Review files before publishing.
- Backups are stored under ~/.local/state/arch-dotfiles/backups; root backups under /var/backups/arch-dotfiles.
- No VM or graphical runtime validation has been performed.

## After installation
Test SilentSDDM with its upstream test.sh in a graphical session, then `sudo systemctl enable sddm.service` only after confirming the greeter works. On the X390 inspect `sensors` and `/proc/acpi/ibm/fan` before enabling Thinkfan. Configure Timeshift and Syncthing separately. Keep a rescue USB and external backup before formatting.
