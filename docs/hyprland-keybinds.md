# Hyprland Keybinds

This documents the keybinds currently defined in `modules/desktop/hyprland.nix`.

`Super` means the Windows key / `Mod4`.

## Launching

- `Super+Enter`: Open the terminal
- `Super+Shift+Enter`: Open a floating terminal
- `Super+D`: Open the app launcher
- `Super+B`: Open Brave
- `Super+Shift+F`: Open Brave
- `Super+E`: Open Thunar
- `Super+Ctrl+L`: Lock the screen
- `Super+Alt+L`: Lock the screen

## Wallpaper Cycling

- `Super+Ctrl+N`: Switch to the next wallpaper and recolor the desktop
- `Super+Ctrl+Shift+N`: Switch to the previous wallpaper and recolor the desktop
- `wallpaperctl next`: Switch to the next wallpaper manually
- `wallpaperctl prev`: Switch to the previous wallpaper manually
- `wallpaperctl apply`: Reapply the current wallpaper and regenerate colors
- `wallpaperctl current`: Print the currently selected wallpaper
- `wallpaperctl list`: Print every wallpaper currently visible to the live system

Wallpapers are read from:

- `assets/wallpapers/` in the repo
- `~/Pictures/Wallpapers/` on the machine

If you add wallpapers to `~/Pictures/Wallpapers/`, `wallpaperctl` can use them immediately without a rebuild. If you add them to `assets/wallpapers/`, rebuild first so the new files are included in the flake.

## Session

- `Super+Q`: Close the focused window
- `Super+Shift+Q`: Exit Hyprland
- `Super+Shift+E`: Exit Hyprland
- `Super+Shift+C`: Reload Hyprland config
- `Super+Shift+R`: Reload Hyprland config

## Screenshots

- `Print`: Copy a full screenshot to the clipboard
- `Shift+Print`: Select an area and copy it to the clipboard

## Audio And Brightness

- `Volume Up`: Increase volume by 5%
- `Volume Down`: Decrease volume by 5%
- `Mute`: Toggle output mute
- `Mic Mute`: Toggle microphone mute
- `Brightness Up`: Increase brightness by 10%
- `Brightness Down`: Decrease brightness by 10%

## Focus Movement

- `Super+H`: Focus left
- `Super+J`: Focus down
- `Super+K`: Focus up
- `Super+L`: Focus right
- `Super+Left`: Focus left
- `Super+Down`: Focus down
- `Super+Up`: Focus up
- `Super+Right`: Focus right

## Move Windows

- `Super+Shift+H`: Move window left
- `Super+Shift+J`: Move window down
- `Super+Shift+K`: Move window up
- `Super+Shift+L`: Move window right
- `Super+Shift+Left`: Move window left
- `Super+Shift+Down`: Move window down
- `Super+Shift+Up`: Move window up
- `Super+Shift+Right`: Move window right

## Layout And Workspaces

- `Super+V`: Toggle split direction
- `Super+F`: Toggle fullscreen
- `Super+P`: Toggle pseudotile
- `Super+Ctrl+P`: Float all windows on the current workspace
- `Super+Ctrl+Shift+P`: Set all floating windows on the current workspace back to tiled
- `Super+Ctrl+T`: Raise the focused floating window to the top
- `Super+S`: Toggle the special workspace
- `Super+Shift+S`: Pin the focused window
- `Super+A`: Cycle layout message / next layout
- `Super+Space`: Cycle to next window in layout order
- `Super+Tab`: Go to the previous workspace
- `Alt+Tab`: Cycle to the next window
- `Alt+Shift+Tab`: Cycle to the previous window
- `Super+[` : Previous workspace
- `Super+]`: Next workspace
- `Super+-`: Show or hide the special workspace
- `Super+Shift+-`: Send the focused window to the special workspace

### Workspace Desktop Mode

Use these together if you want the current workspace to behave more like a normal overlapping desktop:

- `Super+Ctrl+P`: Float everything currently open on the active workspace
- `Super+Ctrl+Shift+P`: Put floating windows on the active workspace back into tiling
- `Super+Ctrl+T`: Raise the focused floating window to the top of the stack

After `Super+Ctrl+P`, windows are also resized and cascaded so the workspace behaves more like a classic overlapping desktop instead of keeping the old tiled geometry.

## Floating Windows

- `Super+Shift+Space`: Toggle floating for the focused window
- `Super+Ctrl+Space`: Force the focused window to become floating
- `Super+Shift+M`: Center the focused floating window
- `Super+Shift+V`: Make the focused window floating, resize it, and center it

## Floating Window Movement

- `Super+Ctrl+H`: Move the focused floating window left
- `Super+Ctrl+J`: Move the focused floating window down
- `Super+Ctrl+K`: Move the focused floating window up
- `Super+Ctrl+L`: Move the focused floating window right
- `Super+Ctrl+Left`: Resize the focused window narrower
- `Super+Ctrl+Right`: Resize the focused window wider
- `Super+Ctrl+Up`: Resize the focused window shorter
- `Super+Ctrl+Down`: Resize the focused window taller

## Workspace Numbers

- `Super+1` through `Super+0`: Switch to workspaces `1` through `10`
- `Super+Shift+1` through `Super+Shift+0`: Move the focused window to workspaces `1` through `10`

## Mouse Actions

- `Super+Left Mouse Drag`: Move a floating window
- `Super+Right Mouse Drag`: Resize a floating window

## Notes

- Plain `Backspace` should delete one character.
- `Ctrl+Backspace` should delete the previous word.
- `Ctrl+Left` and `Ctrl+Right` should move by word in the terminal.
- Wallpaper-driven recoloring currently updates the wallpaper, Waybar, launcher theme, and Hyprland border/shadow colors.
