# Custom NixOS Config

This repo is a NixOS flake for a custom desktop environment built around Hyprland.

## What it does

- Exposes `nixosConfigurations.default`
- Automatically imports `/etc/nixos/hardware-configuration.nix` when run on the target machine
- Enables flakes, NetworkManager, OpenSSH, Zsh, and a Hyprland desktop
- Installs the packages and services needed for the desktop
- Keeps the full user-facing config in a separate dotfiles workflow instead of generating it from NixOS modules
- Provides a tiny fallback Hyprland config so a fresh install can still log in and open a terminal before dotfiles are stowed
- Adds `~/.local/bin` to `PATH` globally so stowed helper scripts work in graphical sessions

## Fallback Session

If your separate dotfiles repo is not cloned or stowed yet, this flake still installs a minimal Hyprland session through `/etc/xdg/hypr/hyprland.conf`.

That fallback session is intentionally basic and is only meant to get you to a usable desktop with a terminal:

- `Super+Enter`: open `alacritty`
- `Super+D`: open `rofi`
- `Super+E`: open `thunar`
- `Super+Q`: close the focused window
- `Super+Shift+Q`: exit Hyprland
- `Super+1` through `Super+0`: switch workspaces

Once your dotfiles are installed, your user-level config should take over and replace this fallback behavior.

## Intended Workflow

The intended bootstrap flow is:

1. Install the system and rebuild this flake.
2. Log in using the fallback Hyprland session or a TTY.
3. Clone your separate dotfiles repo.
4. Run `stow` to link the user config into your home directory.
5. Log out and back in.

Nix should install the software and session plumbing. Your dotfiles repo should own the actual Hyprland, Waybar, shell, and terminal configuration.

## Dotfiles Layout

The full user environment is expected to live in your separate dotfiles repo. The old in-repo layout looked like:

- `dotfiles/shell/.zshrc`
- `dotfiles/alacritty/.config/alacritty/alacritty.toml`
- `dotfiles/hypr/.config/hypr/hyprland.conf`
- `dotfiles/waybar/.config/waybar/`
- `dotfiles/bin/.local/bin/`

The intention is that NixOS installs the software and gives you a basic rescue desktop, while your actual desktop config is managed with `stow`.

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

If you have moved the dotfiles to a separate repository, clone that repo first and run the same `stow` command from there.

Because this flake enables `~/.local/bin` in `PATH`, helper scripts from a stowed `bin/.local/bin/` tree should be available automatically after login.

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
