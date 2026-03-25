# Custom NixOS Config

This repo is a NixOS flake for a custom desktop environment built around Hyprland.

## What it does

- Exposes `nixosConfigurations.default`
- Automatically imports `/etc/nixos/hardware-configuration.nix` when run on the target machine
- Enables flakes, NetworkManager, OpenSSH, Zsh, and a Hyprland desktop
- Installs the packages and services needed for the desktop
- Keeps user-facing config in `dotfiles/` instead of generating it from NixOS modules

## Dotfiles Layout

The user environment now lives under `dotfiles/`:

- `dotfiles/shell/.zshrc`
- `dotfiles/alacritty/.config/alacritty/alacritty.toml`
- `dotfiles/hypr/.config/hypr/hyprland.conf`
- `dotfiles/waybar/.config/waybar/`
- `dotfiles/bin/.local/bin/`

The intention is that NixOS installs the software, and you manage the actual desktop config with `stow`.

## Install And Deploy

### Deploy from a GitHub repo

For a public GitHub repo, use your actual `owner/repo` flake reference:

```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild boot --flake github:kayes817/nixos-build#default --impure -L
sudo reboot
```

### Deploy from `/mnt`

If the repo is mounted locally at `/mnt`:

```bash
cd /mnt
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake .#default --impure -L
```

For login/session changes:

```bash
cd /mnt
sudo NIXOS_NO_BOOTLOADER=1 NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild boot --flake .#default --impure -L
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

## Stow The Dotfiles

After the system packages are installed, link the user config into your home directory:

```bash
cd /path/to/repo/dotfiles
stow -t "$HOME" shell alacritty hypr waybar bin
```

If you update the files in `dotfiles/`, re-run the same `stow` command.

## First Things To Customize

- `networking.hostName` in `modules/hosts/default.nix`
- `users.users.r48817` in `modules/hosts/default.nix`
- `time.timeZone` in `modules/hosts/default.nix`
- Packages and services in `modules/desktop/hyprland.nix`
- General packages in `modules/desktop/general.nix`
- Security tooling in `modules/tools/rednix.nix`
- User-facing shell / Hyprland / Waybar / Alacritty config in `dotfiles/`

This repo currently manages an explicit user account in the host module.

## Docs

- Hyprland keybinds: `docs/hyprland-keybinds.md`

## Wallpapers And Dynamic Colors

Wallpapers are expected in:

- `~/Pictures/Wallpapers/`
- `~/.local/share/wallpapers/`

This setup includes a `wallpaperctl` helper that:

- cycles through images in your wallpaper folders
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

`wallpaperctl list` is the fastest way to verify which wallpapers the live system can currently see.
