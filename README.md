# Custom NixOS Config

This repo is a NixOS flake for a custom desktop environment built around Hyprland.

## What it does

- Exposes `nixosConfigurations.default`
- Automatically imports `/etc/nixos/hardware-configuration.nix` when run on the target machine
- Enables flakes, NetworkManager, OpenSSH, Zsh, and a Hyprland desktop
- Includes custom desktop modules, tools, theming, and keybinds

## Install And Deploy

### Deploy from `/mnt`

If the repo is mounted locally at `/mnt`, deploy it with:

```bash
cd /mnt
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake .#default --impure -L
```

If you are changing boot, display manager, or session stack, prefer:

```bash
cd /mnt
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild boot --flake .#default --impure -L
sudo reboot
```

`--impure` is required here because the host config imports `/etc/nixos/hardware-configuration.nix`.

### Deploy from a GitHub repo

For a public GitHub repo, use your actual `owner/repo` flake reference:

```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake github:<owner>/<repo>#default --impure -L
```

For bigger login/session changes, use:

```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild boot --flake github:<owner>/<repo>#default --impure -L
sudo reboot
```

If the repo is private, the simplest path is usually:

```bash
git clone git@github.com:<owner>/<repo>.git
cd <repo>
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake .#default --impure -L
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
- `time.timeZone` in `modules/hosts/default.nix`
- Desktop/services/packages in `modules/desktop/hyprland.nix`
- General packages in `modules/desktop/general.nix`
- Security tooling in `modules/tools/rednix.nix`

This repo does not manage a specific named user anymore. The account you created during NixOS installation can be kept as-is.

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
