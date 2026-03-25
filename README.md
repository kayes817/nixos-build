# Custom NixOS Config

This repo is a NixOS flake for a custom desktop environment built around Hyprland.

## What it does

- Exposes `nixosConfigurations.default`
- Automatically imports `/etc/nixos/hardware-configuration.nix` when run on the target machine
- Enables flakes, NetworkManager, OpenSSH, Zsh, and a Hyprland desktop
- Includes custom desktop modules, tools, theming, and keybinds

## Install And Deploy

### Deploy from a GitHub repo

For a public GitHub repo, use your actual `owner/repo` flake reference:

```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild boot --flake github:kayes817/nixos-build#default --impure -L
sudo reboot
```

### Deploy from `/etc/nixos`

If you copy this repo into `/etc/nixos`, use:

```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake /etc/nixos#default --impure -L
```

Or for boot/session changes:

```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild boot --flake /etc/nixos#default --impure -L
sudo reboot
```

## First things to customize

- `networking.hostName` in `modules/hosts/default.nix`
- `users.users.r48817` in `modules/hosts/default.nix`
- `time.timeZone` in `modules/hosts/default.nix`
- Desktop/services/packages in `modules/desktop/hyprland.nix`
- General packages in `modules/desktop/general.nix`
- Security tooling in `modules/tools/rednix.nix`

This repo currently manages an explicit user account in the host module.

## Docs

- Hyprland keybinds: `docs/hyprland-keybinds.md`

## Wallpapers And Dynamic Colors

Wallpapers can live in either:

- `assets/wallpapers/` in the repo
- `~/Pictures/Wallpapers/` on the machine

This setup includes a `wallpaperctl` helper that:

- cycles through images in `assets/wallpapers/`
- applies the selected wallpaper with `swaybg`
- extracts colors from the current image
- regenerates the Waybar theme, launcher theme, and Hyprland border/shadow colors

Useful commands:

```bash
wallpaperctl next
wallpaperctl prev
wallpaperctl apply
wallpaperctl current
wallpaperctl list
```

Useful keybinds:

- `Super+Ctrl+N`: next wallpaper
- `Super+Ctrl+Shift+N`: previous wallpaper

If you add wallpapers to `~/Pictures/Wallpapers/`, `wallpaperctl` can use them immediately.

Important: `assets/wallpapers/` is part of the flake input, so if you add or remove wallpaper files there, run another rebuild before `wallpaperctl` will see the new set.

`wallpaperctl list` is the fastest way to verify which wallpapers the live system can currently see.
