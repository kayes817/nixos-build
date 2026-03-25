{ pkgs, ... }:
let
  mod = "SUPER";
  bg = "rgba(2e3440ee)";
  mantle = "#3b4252";
  surface0 = "#434c5e";
  surface1 = "#4c566a";
  text = "#eceff4";
  subtext = "#d8dee9";
  blue = "#d580ff";
  red = "#bf616a";
  teal = "#8fbcbb";
  wallpaperDir = ../../assets/wallpapers;
  sddmBackground = pkgs.runCommandLocal "sddm-background" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    magick -size 1920x1080 xc:'#232733' $out/background.png
  '';
  sddmThemeConfig = pkgs.writeText "theme.conf" ''
    [General]
    background=${sddmBackground}/background.png
    backgroundMode=fill
    backgroundFill=#232733
    basicTextColor=#eceff4
    passwordCharacter=*
    passwordMask=true
    passwordFontSize=16
    passwordInputWidth=0.24
    passwordInputBackground=#2b3040
    passwordInputRadius=0
    passwordCursorColor=#d580ff
    passwordTextColor=#eceff4
    usersFontSize=18
    sessionsFontSize=12
    font=JetBrainsMono Nerd Font
    showSessionsByDefault=true
    showUsersByDefault=true
    showUserRealNameByDefault=false
    hideCursor=false
  '';
  sddmThemePackage = pkgs.where-is-my-sddm-theme.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      cp ${sddmThemeConfig} $out/share/sddm/themes/where_is_my_sddm_theme/theme.conf
    '';
    meta = old.meta or { };
    passthru = old.passthru or { };
    name = "where-is-my-sddm-theme-custom";
    pname = "where-is-my-sddm-theme-custom";
  });

  wallpaperCtl = pkgs.writeShellScriptBin "wallpaperctl" ''
    set -euo pipefail

    STATE_DIR="$HOME/.local/state/hypr-theme"
    ROFI_DIR="$HOME/.config/rofi"
    WAYBAR_DIR="$HOME/.config/waybar"
    USER_WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    CURRENT_INDEX="$STATE_DIR/current-index"

    mkdir -p "$STATE_DIR" "$ROFI_DIR" "$WAYBAR_DIR" "$USER_WALLPAPER_DIR"

    mapfile -t WALLPAPERS < <(
      {
        ${pkgs.findutils}/bin/find ${wallpaperDir} -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null
        ${pkgs.findutils}/bin/find "$USER_WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null
      } | ${pkgs.coreutils}/bin/sort -u
    )

    if [ "''${#WALLPAPERS[@]}" -eq 0 ]; then
      echo "No wallpapers found in ${wallpaperDir} or $USER_WALLPAPER_DIR" >&2
      exit 1
    fi

    hex_up() {
      printf '%s' "$1" | ${pkgs.coreutils}/bin/tr '[:lower:]' '[:upper:]'
    }

    mix_hex() {
      ${pkgs.gawk}/bin/awk -v c1="$1" -v c2="$2" -v t="$3" '
        function h2d(h) { return strtonum("0x" h) }
        BEGIN {
          r1 = h2d(substr(c1,1,2)); g1 = h2d(substr(c1,3,2)); b1 = h2d(substr(c1,5,2));
          r2 = h2d(substr(c2,1,2)); g2 = h2d(substr(c2,3,2)); b2 = h2d(substr(c2,5,2));
          r = int((r1 * t) + (r2 * (1 - t)) + 0.5);
          g = int((g1 * t) + (g2 * (1 - t)) + 0.5);
          b = int((b1 * t) + (b2 * (1 - t)) + 0.5);
          printf "%02X%02X%02X", r, g, b;
        }'
    }

    alpha_hex() {
      printf '%s%s' "$1" "$2"
    }

    pick_accent() {
      ${pkgs.imagemagick}/bin/magick "$1" -resize 256x256\> -colors 12 -depth 8 histogram:info:- \
        | ${pkgs.gawk}/bin/awk '
            function h2d(h) { return strtonum("0x" h) }
            match($0, /#([0-9A-Fa-f]{6})/, m) {
              hex = toupper(m[1]);
              r = h2d(substr(hex,1,2)); g = h2d(substr(hex,3,2)); b = h2d(substr(hex,5,2));
              max = r; if (g > max) max = g; if (b > max) max = b;
              min = r; if (g < min) min = g; if (b < min) min = b;
              sat = (max == 0) ? 0 : (max - min) / max;
              val = max / 255;
              if (val > 0.20) {
                score = sat * 0.80 + val * 0.20;
                printf "%.6f %s\n", score, hex;
              }
            }' \
        | ${pkgs.coreutils}/bin/sort -nr \
        | ${pkgs.gawk}/bin/awk 'NR == 1 { print $2 }'
    }

    avg_hex() {
      ${pkgs.imagemagick}/bin/magick "$1" -resize 1x1\! -format '%[hex:p{0,0}]' info:
    }

    wallpaper_name() {
      ${pkgs.coreutils}/bin/basename "$1"
    }

    current_index() {
      if [ -f "$CURRENT_INDEX" ]; then
        idx="$(${pkgs.coreutils}/bin/cat "$CURRENT_INDEX")"
        if ${pkgs.gnugrep}/bin/grep -Eq '^[0-9]+$' <<EOF
$idx
EOF
        then
          if [ "$idx" -ge 0 ] && [ "$idx" -lt "''${#WALLPAPERS[@]}" ]; then
            printf '%s\n' "$idx"
            return
          fi
        fi
      fi
      printf '0\n'
    }

    current_wallpaper() {
      idx="$(current_index)"
      printf '%s\n' "''${WALLPAPERS[$idx]}"
    }

    rotate_wallpaper() {
      local direction="$1"
      local idx
      idx="$(current_index)"

      if [ "$direction" = "next" ]; then
        idx=$(( (idx + 1) % ''${#WALLPAPERS[@]} ))
      else
        idx=$(( (idx - 1 + ''${#WALLPAPERS[@]}) % ''${#WALLPAPERS[@]} ))
      fi

      printf '%s\n' "$idx"
    }

    apply_wallpaper() {
      local wallpaper="$1"
      local idx="$2"
      printf '%s\n' "$idx" > "$CURRENT_INDEX"

      local avg accent bg_hex panel_hex selected_hex accent_soft inactive_hex shadow_hex
      avg="$(hex_up "$(avg_hex "$wallpaper")")"
      accent="$(hex_up "$(pick_accent "$wallpaper")")"
      if [ -z "$accent" ]; then
        accent="$(mix_hex "$avg" "88C0D0" 0.28)"
      fi

      bg_hex="$(mix_hex "$avg" "232733" 0.18)"
      panel_hex="$(mix_hex "$avg" "2B3040" 0.16)"
      selected_hex="$(mix_hex "$accent" "$panel_hex" 0.24)"
      accent_soft="$(mix_hex "$accent" "$panel_hex" 0.28)"
      inactive_hex="$(mix_hex "$accent" "3B4252" 0.20)"
      shadow_hex="$(alpha_hex "$accent" "33")"

      cat > "$ROFI_DIR/current-theme.rasi" <<EOF
configuration {
  modi: "drun,run,window";
  show-icons: true;
  display-drun: "";
  display-run: "Run";
  display-window: "Windows";
  drun-display-format: "{name}";
  drun-match-fields: "name,generic,exec,categories,keywords";
  matching: "fzf";
  sort: true;
  case-sensitive: false;
  cycle: false;
}

* {
  bg: #$bg_hex;
  bg-alt: #$panel_hex;
  fg: #ECEFF4;
  fg-alt: #B8C0D4;
  accent: #$accent;
  selected: #$selected_hex;
  border: #$accent;
  border-soft: #$accent_soft;
  border-radius: 0px;
  font: "JetBrainsMono Nerd Font 12";
}

window {
  width: 42%;
  padding: 16px;
  border: 1px;
  border-color: @border-soft;
  border-radius: @border-radius;
  background-color: @bg;
}

mainbox {
  spacing: 12px;
  background-color: transparent;
}

inputbar {
  padding: 10px 12px;
  border: 1px;
  border-radius: 0px;
  border-color: @border;
  background-color: @bg-alt;
  text-color: @fg;
}

prompt {
  enabled: false;
  background-color: transparent;
  padding: 0;
}

textbox-prompt-colon {
  str: "";
}

entry {
  background-color: transparent;
  text-color: @fg;
  placeholder: "Search apps, commands, windows";
  placeholder-color: @fg-alt;
}

listview {
  lines: 9;
  columns: 1;
  spacing: 8px;
  scrollbar: false;
  background-color: transparent;
}

element {
  padding: 11px 14px;
  border: 1px;
  border-radius: 0px;
  border-color: transparent;
  background-color: @bg-alt;
  text-color: @fg;
}

element selected {
  background-color: @selected;
  text-color: @fg;
  border: 1px;
  border-color: @accent;
}

element-text {
  background-color: transparent;
  text-color: inherit;
  vertical-align: 0.5;
}

element-icon {
  size: 24px;
  margin: 0 12px 0 0;
}
EOF

      cat > "$WAYBAR_DIR/style.css" <<EOF
* {
  border: none;
  border-radius: 0;
  font-family: "JetBrainsMono Nerd Font";
  font-size: 12px;
  min-height: 0;
}

window#waybar {
  background: #$bg_hex;
  color: #eceff4;
  border-bottom: 1px solid #$accent;
}

#workspaces {
  margin-left: 8px;
}

#workspaces button {
  padding: 4px 8px;
  color: #d8dee9;
  background: transparent;
}

#workspaces button.active {
  color: #1f2330;
  background: #$accent;
}

#custom-lan,
#custom-tailscale,
#custom-ram,
#custom-disk,
#clock {
  margin: 0 8px 0 0;
  color: #eceff4;
}

#custom-lan {
  color: #$accent;
}

#custom-tailscale {
  color: #8fbcbb;
}
EOF

      ${pkgs.hyprland}/bin/hyprctl keyword general:col.active_border "rgb($accent)" >/dev/null 2>&1 || true
      ${pkgs.hyprland}/bin/hyprctl keyword general:col.inactive_border "rgb($inactive_hex)" >/dev/null 2>&1 || true
      ${pkgs.hyprland}/bin/hyprctl keyword decoration:shadow:color "rgba($shadow_hex)" >/dev/null 2>&1 || true

      ${pkgs.procps}/bin/pkill swaybg >/dev/null 2>&1 || true
      ${pkgs.swaybg}/bin/swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &

      ${pkgs.procps}/bin/pkill waybar >/dev/null 2>&1 || true
      ${pkgs.waybar}/bin/waybar -c /etc/xdg/waybar/config.jsonc -s "$WAYBAR_DIR/style.css" >/dev/null 2>&1 &
    }

    command="''${1:-apply}"
    case "$command" in
      apply)
        idx="$(current_index)"
        apply_wallpaper "''${WALLPAPERS[$idx]}" "$idx"
        ;;
      next)
        idx="$(rotate_wallpaper next)"
        apply_wallpaper "''${WALLPAPERS[$idx]}" "$idx"
        ;;
      prev)
        idx="$(rotate_wallpaper prev)"
        apply_wallpaper "''${WALLPAPERS[$idx]}" "$idx"
        ;;
      current)
        current_wallpaper
        ;;
      list)
        printf '%s\n' "''${WALLPAPERS[@]}"
        ;;
      *)
        echo "Usage: wallpaperctl {apply|next|prev|current|list}" >&2
        exit 1
        ;;
    esac
  '';

  wallpaperInitScript = pkgs.writeShellScript "hypr-wallpaper-init" ''
    ${wallpaperCtl}/bin/wallpaperctl apply
  '';

  rofiLauncherScript = pkgs.writeShellScript "hypr-rofi-launcher" ''
    if [ ! -f "$HOME/.config/rofi/current-theme.rasi" ]; then
      ${wallpaperCtl}/bin/wallpaperctl apply
    fi
    exec ${pkgs.rofi}/bin/rofi -show drun -theme "$HOME/.config/rofi/current-theme.rasi" -show-icons -drun-match-fields name,generic,exec,categories,keywords -drun-display-format '{name}' -matching fuzzy -sort
  '';

  hyprlockLauncherScript = pkgs.writeShellScript "hypr-lock-launcher" ''
    exec ${pkgs.swaylock}/bin/swaylock \
      --color 232733 \
      --indicator-idle-visible \
      --indicator-radius 110 \
      --indicator-thickness 8 \
      --font "JetBrainsMono Nerd Font" \
      --font-size 18 \
      --inside-color 2b3040ee \
      --inside-clear-color 2b3040ee \
      --inside-ver-color 2b3040ee \
      --inside-wrong-color 2b3040ee \
      --ring-color d580ffff \
      --ring-clear-color 8fbcbbff \
      --ring-ver-color 8fbcbbff \
      --ring-wrong-color bf616aff \
      --line-color 2b304000 \
      --separator-color 2b304000 \
      --key-hl-color d580ffff \
      --bs-hl-color bf616aff \
      --text-color eceff4ff \
      --text-clear-color eceff4ff \
      --text-ver-color eceff4ff \
      --text-wrong-color eceff4ff \
      --layout-text-color d8dee9ff \
      --datestr "%A, %B %d" \
      --timestr "%H:%M"
  '';

  hostIpScript = pkgs.writeShellScript "waybar-host-ip" ''
    ip="$(${pkgs.iproute2}/bin/ip route get 1.1.1.1 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP 'src \K\S+' | ${pkgs.coreutils}/bin/head -n1)"
    if [ -z "$ip" ]; then
      echo "LAN offline"
    else
      echo "LAN $ip"
    fi
  '';

  tailscaleIpScript = pkgs.writeShellScript "waybar-tailscale-ip" ''
    ip="$(${pkgs.iproute2}/bin/ip -4 addr show dev tailscale0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP 'inet \K[0-9.]+' | ${pkgs.coreutils}/bin/head -n1)"
    if [ -z "$ip" ]; then
      echo "TS down"
    else
      echo "TS $ip"
    fi
  '';

  ramScript = pkgs.writeShellScript "waybar-ram" ''
    used="$(${pkgs.procps}/bin/free -m | ${pkgs.gawk}/bin/awk '/^Mem:/ {print $3}')"
    total="$(${pkgs.procps}/bin/free -m | ${pkgs.gawk}/bin/awk '/^Mem:/ {print $2}')"
    used_gib="$(${pkgs.gawk}/bin/awk "BEGIN {printf \"%.1f\", $used/1024}")"
    total_gib="$(${pkgs.gawk}/bin/awk "BEGIN {printf \"%.1f\", $total/1024}")"
    echo "RAM $used_gib/$total_gib GiB"
  '';

  diskScript = pkgs.writeShellScript "waybar-disk" ''
    free="$(${pkgs.coreutils}/bin/df -h / | ${pkgs.gawk}/bin/awk 'NR==2 {print $4}')"
    echo "Disk $free free"
  '';

  floatCenterScript = pkgs.writeShellScript "hypr-float-center" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch setfloating active
    ${pkgs.hyprland}/bin/hyprctl dispatch resizeactive exact 1366 768
    ${pkgs.hyprland}/bin/hyprctl dispatch centerwindow
  '';

  centerScript = pkgs.writeShellScript "hypr-center" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch centerwindow
  '';

  floatOnlyScript = pkgs.writeShellScript "hypr-float-only" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch setfloating active
  '';

  floatWorkspaceScript = pkgs.writeShellScript "hypr-float-workspace" ''
    current_id="$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')"
    workspace_json="$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j)"
    monitor_w="$(${pkgs.jq}/bin/jq -r '.w // 1280' <<< "$workspace_json")"
    monitor_h="$(${pkgs.jq}/bin/jq -r '.h // 800' <<< "$workspace_json")"
    win_w=$(( monitor_w * 68 / 100 ))
    win_h=$(( monitor_h * 72 / 100 ))
    base_x=$(( monitor_w * 12 / 100 ))
    base_y=$(( monitor_h * 10 / 100 ))
    step_x=48
    step_y=36
    idx=0

    ${pkgs.hyprland}/bin/hyprctl clients -j \
      | ${pkgs.jq}/bin/jq -r --argjson ws "$current_id" '.[] | select(.workspace.id == $ws) | .address' \
      | while read -r addr; do
          [ -n "$addr" ] || continue
          ${pkgs.hyprland}/bin/hyprctl dispatch setfloating "address:$addr" >/dev/null
          x=$(( base_x + (idx * step_x) ))
          y=$(( base_y + (idx * step_y) ))
          ${pkgs.hyprland}/bin/hyprctl dispatch resizewindowpixel exact "$win_w" "$win_h","address:$addr" >/dev/null 2>&1 || true
          ${pkgs.hyprland}/bin/hyprctl dispatch movewindowpixel exact "$x" "$y","address:$addr" >/dev/null 2>&1 || true
          idx=$(( idx + 1 ))
        done
  '';

  unfloatWorkspaceScript = pkgs.writeShellScript "hypr-unfloat-workspace" ''
    current_id="$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')"
    ${pkgs.hyprland}/bin/hyprctl clients -j \
      | ${pkgs.jq}/bin/jq -r --argjson ws "$current_id" '.[] | select(.workspace.id == $ws and .floating == true) | .address' \
      | while read -r addr; do
          [ -n "$addr" ] || continue
          ${pkgs.hyprland}/bin/hyprctl dispatch settiled "address:$addr" >/dev/null
        done
  '';

  moveLeftScript = pkgs.writeShellScript "hypr-move-left" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch moveactive -40 0
  '';

  moveDownScript = pkgs.writeShellScript "hypr-move-down" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch moveactive 0 40
  '';

  moveUpScript = pkgs.writeShellScript "hypr-move-up" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch moveactive 0 -40
  '';

  moveRightScript = pkgs.writeShellScript "hypr-move-right" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch moveactive 40 0
  '';

  alacrittyConfig = pkgs.writeText "alacritty.toml" ''
    [window]
    opacity = 0.98
    padding = { x = 12, y = 12 }
    decorations = "full"
    dynamic_padding = true

    [font]
    size = 11.5

    [font.normal]
    family = "JetBrainsMono Nerd Font"
    style = "Regular"

    [[keyboard.bindings]]
    key = "Left"
    mods = "Control"
    chars = "\u001bb"

    [[keyboard.bindings]]
    key = "Left"
    mods = "Alt"
    chars = "\u001bb"

    [[keyboard.bindings]]
    key = "Right"
    mods = "Control"
    chars = "\u001bf"

    [[keyboard.bindings]]
    key = "Right"
    mods = "Alt"
    chars = "\u001bf"

    [[keyboard.bindings]]
    key = "Back"
    mods = "Control"
    chars = "\u0017"

    [[keyboard.bindings]]
    key = "Home"
    chars = "\u0001"

    [[keyboard.bindings]]
    key = "End"
    chars = "\u0005"

    [colors.primary]
    background = "#2e3440"
    foreground = "#eceff4"

    [colors.normal]
    black = "#3b4252"
    red = "#bf616a"
    green = "#a3be8c"
    yellow = "#ebcb8b"
    blue = "#81a1c1"
    magenta = "#b48ead"
    cyan = "#88c0d0"
    white = "#e5e9f0"

    [colors.bright]
    black = "#4c566a"
    red = "#bf616a"
    green = "#a3be8c"
    yellow = "#ebcb8b"
    blue = "#81a1c1"
    magenta = "#b48ead"
    cyan = "#8fbcbb"
    white = "#eceff4"
  '';

  rofiTheme = pkgs.writeText "rofi-cyberbunny.rasi" ''
    configuration {
      modi: "drun,run,window";
      show-icons: true;
      display-drun: "";
      display-run: "Run";
      display-window: "Windows";
      drun-display-format: "{name}";
      drun-match-fields: "name,generic,exec,categories,keywords";
      matching: "fzf";
      sort: true;
      case-sensitive: false;
      cycle: false;
    }

    * {
      bg: #232733;
      bg-alt: #2b3040;
      fg: #eceff4;
      fg-alt: #b8c0d4;
      accent: #d580ff;
      selected: #3a3146;
      border: #cf78ff;
      border-soft: #4f4264;
      border-radius: 0px;
      font: "JetBrainsMono Nerd Font 12";
    }

    window {
      width: 42%;
      padding: 16px;
      border: 1px;
      border-color: @border-soft;
      border-radius: @border-radius;
      background-color: @bg;
    }

    mainbox {
      spacing: 12px;
      background-color: transparent;
    }

    inputbar {
      padding: 10px 12px;
      border: 1px;
      border-radius: 0px;
      border-color: @border;
      background-color: @bg-alt;
      text-color: @fg;
    }

    prompt {
      enabled: false;
      background-color: transparent;
      padding: 0;
    }

    textbox-prompt-colon {
      str: "";
    }

    entry {
      background-color: transparent;
      text-color: @fg;
      placeholder: "Search apps, commands, windows";
      placeholder-color: @fg-alt;
    }

    listview {
      lines: 9;
      columns: 1;
      spacing: 8px;
      scrollbar: false;
      background-color: transparent;
    }

    element {
      padding: 11px 14px;
      border: 1px;
      border-radius: 0px;
      border-color: transparent;
      background-color: @bg-alt;
      text-color: @fg;
    }

    element selected {
      background-color: @selected;
      text-color: @fg;
      border: 1px;
      border-color: @accent;
    }

    element-text {
      background-color: transparent;
      text-color: inherit;
      vertical-align: 0.5;
    }

    element-icon {
      size: 24px;
      margin: 0 12px 0 0;
    }
  '';

  hyprConfig = pkgs.writeText "hyprland.conf" ''
    $mod = ${mod}
    $terminal = ${pkgs.alacritty}/bin/alacritty --config-file ${alacrittyConfig}
    $browser = ${pkgs.brave}/bin/brave
    $fileManager = ${pkgs.thunar}/bin/thunar
    $menu = ${rofiLauncherScript}
    $lock = ${hyprlockLauncherScript}

    monitor = ,preferred,auto,1

    env = XCURSOR_THEME,Adwaita
    env = XCURSOR_SIZE,24
    env = HYPRCURSOR_THEME,Adwaita
    env = HYPRCURSOR_SIZE,24
    env = NIXOS_OZONE_WL,1
    env = WLR_NO_HARDWARE_CURSORS,1
    env = WLR_RENDERER_ALLOW_SOFTWARE,1
    env = LIBGL_ALWAYS_SOFTWARE,1

    exec-once = ${wallpaperInitScript}
    exec-once = ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
    exec-once = ${pkgs.pasystray}/bin/pasystray
    exec-once = ${pkgs.dunst}/bin/dunst
    exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1

    input {
      kb_layout = us
      follow_mouse = 1
      touchpad {
        natural_scroll = false
      }
    }

    general {
      gaps_in = 10
      gaps_out = 4
      border_size = 2
      col.active_border = rgb(88c0d0)
      col.inactive_border = rgb(4c566a)
      resize_on_border = true
      layout = dwindle
    }

    decoration {
      rounding = 0
      active_opacity = 1.0
      inactive_opacity = 0.95

      shadow {
        enabled = true
        range = 18
        render_power = 3
        color = rgba(88c0d033)
      }

      blur {
        enabled = true
        size = 6
        passes = 2
        new_optimizations = true
        ignore_opacity = true
        xray = false
      }
    }

    animations {
      enabled = true

      bezier = smooth, 0.22, 1.0, 0.36, 1.0
      bezier = soft, 0.25, 0.1, 0.25, 1.0

      animation = windows, 1, 6, smooth, slide
      animation = windowsOut, 1, 5, soft, slide
      animation = border, 1, 8, soft
      animation = fade, 1, 6, soft
      animation = workspaces, 1, 6, smooth, slidefade
    }

    dwindle {
      pseudotile = true
      preserve_split = true
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      mouse_move_enables_dpms = true
      key_press_enables_dpms = true
    }

    bind = $mod, Return, exec, $terminal
    bind = $mod SHIFT, Return, exec, $terminal --class floating-term
    bind = $mod, D, exec, $menu
    bind = $mod, B, exec, $browser
    bind = $mod SHIFT, F, exec, $browser
    bind = $mod, E, exec, $fileManager
    bind = $mod CTRL, L, exec, $lock
    bind = $mod ALT, L, exec, $lock
    bind = $mod, Q, killactive,
    bind = $mod SHIFT, Q, exit,
    bind = $mod SHIFT, E, exit,
    bind = $mod SHIFT, C, exec, ${pkgs.hyprland}/bin/hyprctl reload
    bind = $mod SHIFT, R, exec, ${pkgs.hyprland}/bin/hyprctl reload

    bind = , Print, exec, ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy
    bind = SHIFT, Print, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
    bind = , XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5
    bind = , XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5
    bind = , XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer -t
    bind = , XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source -t
    bind = , XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +10%
    bind = , XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-

    bind = $mod, H, movefocus, l
    bind = $mod, J, movefocus, d
    bind = $mod, K, movefocus, u
    bind = $mod, L, movefocus, r
    bind = $mod, left, movefocus, l
    bind = $mod, down, movefocus, d
    bind = $mod, up, movefocus, u
    bind = $mod, right, movefocus, r

    bind = $mod SHIFT, H, movewindow, l
    bind = $mod SHIFT, J, movewindow, d
    bind = $mod SHIFT, K, movewindow, u
    bind = $mod SHIFT, L, movewindow, r
    bind = $mod SHIFT, left, movewindow, l
    bind = $mod SHIFT, down, movewindow, d
    bind = $mod SHIFT, up, movewindow, u
    bind = $mod SHIFT, right, movewindow, r

    bind = $mod, V, togglesplit,
    bind = $mod, F, fullscreen, 0
    bind = $mod, P, pseudo,
    bind = $mod CTRL, P, exec, ${floatWorkspaceScript}
    bind = $mod CTRL SHIFT, P, exec, ${unfloatWorkspaceScript}
    bind = $mod CTRL, T, bringactivetotop
    bind = $mod CTRL, N, exec, ${wallpaperCtl}/bin/wallpaperctl next
    bind = $mod CTRL SHIFT, N, exec, ${wallpaperCtl}/bin/wallpaperctl prev
    bind = $mod, S, togglespecialworkspace,
    bind = $mod SHIFT, S, pin,
    bind = $mod, A, layoutmsg, cyclenext
    bind = $mod, SPACE, cyclenext
    bind = $mod, TAB, workspace, previous
    bind = ALT, TAB, cyclenext
    bind = ALT SHIFT, TAB, cyclenext, prev
    bind = $mod, bracketleft, workspace, e-1
    bind = $mod, bracketright, workspace, e+1
    bind = $mod SHIFT, SPACE, togglefloating,
    bind = $mod CTRL, SPACE, exec, ${floatOnlyScript}
    bind = $mod SHIFT, M, exec, ${centerScript}
    bind = $mod SHIFT, V, exec, ${floatCenterScript}
    bind = $mod CTRL, H, exec, ${moveLeftScript}
    bind = $mod CTRL, J, exec, ${moveDownScript}
    bind = $mod CTRL, K, exec, ${moveUpScript}
    bind = $mod CTRL, L, exec, ${moveRightScript}
    bind = $mod SHIFT, minus, movetoworkspace, special
    bind = $mod, minus, togglespecialworkspace,

    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9
    bind = $mod, 0, workspace, 10

    bind = $mod SHIFT, 1, movetoworkspace, 1
    bind = $mod SHIFT, 2, movetoworkspace, 2
    bind = $mod SHIFT, 3, movetoworkspace, 3
    bind = $mod SHIFT, 4, movetoworkspace, 4
    bind = $mod SHIFT, 5, movetoworkspace, 5
    bind = $mod SHIFT, 6, movetoworkspace, 6
    bind = $mod SHIFT, 7, movetoworkspace, 7
    bind = $mod SHIFT, 8, movetoworkspace, 8
    bind = $mod SHIFT, 9, movetoworkspace, 9
    bind = $mod SHIFT, 0, movetoworkspace, 10

    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow

    binde = $mod CTRL, left, resizeactive, -40 0
    binde = $mod CTRL, right, resizeactive, 40 0
    binde = $mod CTRL, up, resizeactive, 0 -40
    binde = $mod CTRL, down, resizeactive, 0 40

  '';

  waybarConfig = pkgs.writeText "waybar-config.jsonc" ''
    {
      "layer": "top",
      "position": "top",
      "height": 30,
      "spacing": 10,
      "modules-left": ["hyprland/workspaces"],
      "modules-center": [],
      "modules-right": ["custom/lan", "custom/tailscale", "custom/ram", "custom/disk", "clock"],

      "hyprland/workspaces": {
        "format": "{name}",
        "all-outputs": true,
        "disable-scroll": true
      },

      "custom/lan": {
        "exec": "${hostIpScript}",
        "interval": 5
      },

      "custom/tailscale": {
        "exec": "${tailscaleIpScript}",
        "interval": 5
      },

      "custom/ram": {
        "exec": "${ramScript}",
        "interval": 5
      },

      "custom/disk": {
        "exec": "${diskScript}",
        "interval": 30
      },

      "clock": {
        "format": "{:%Y-%m-%d %H:%M}",
        "interval": 60
      }
    }
  '';

  waybarStyle = pkgs.writeText "waybar-style.css" ''
    * {
      border: none;
      border-radius: 0;
      font-family: "JetBrainsMono Nerd Font";
      font-size: 12px;
      min-height: 0;
    }

    window#waybar {
      background: rgba(39, 43, 56, 0.88);
      color: #eceff4;
      border-bottom: 1px solid #d580ff;
    }

    #workspaces {
      margin-left: 8px;
    }

    #workspaces button {
      padding: 4px 8px;
      color: #d8dee9;
      background: transparent;
    }

    #workspaces button.active {
      color: #1f2330;
      background: #d580ff;
    }

    #custom-lan,
    #custom-tailscale,
    #custom-ram,
    #custom-disk,
    #clock {
      margin: 0 8px 0 0;
      color: #eceff4;
    }

    #custom-lan {
      color: #d580ff;
    }

    #custom-tailscale {
      color: #8fbcbb;
    }
  '';
in
{
  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    theme = "where_is_my_sddm_theme";
    extraPackages = [
      pkgs.qt6.qt5compat
      sddmThemePackage
    ];
    settings = {
      General = {
        DisplayServer = "x11";
      };
      Theme = {
        Current = "where_is_my_sddm_theme";
        CursorTheme = "Adwaita";
        CursorSize = 24;
      };
      Users = {
        HideShells = true;
        RememberLastSession = true;
        RememberLastUser = true;
      };
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  networking.networkmanager.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  programs.dconf.enable = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  fonts.packages = with pkgs; [
    dejavu_fonts
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  environment.sessionVariables = {
    BROWSER = "brave";
    TERMINAL = "alacritty";
    NIXOS_OZONE_WL = "1";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Adwaita";
    HYPRCURSOR_SIZE = "24";
  };

  environment.etc."xdg/hypr/hyprland.conf".source = hyprConfig;
  environment.etc."xdg/waybar/config.jsonc".source = waybarConfig;
  environment.etc."xdg/waybar/style.css".source = waybarStyle;

  environment.systemPackages = with pkgs; [
    alacritty
    adwaita-icon-theme
    brave
    brightnessctl
    dunst
    grim
    hypridle
    imagemagick
    jq
    networkmanagerapplet
    pamixer
    pasystray
    playerctl
    polkit_gnome
    rofi
    sddmThemePackage
    slurp
    swaylock
    swaybg
    thunar
    thunar-volman
    wallpaperCtl
    waybar
    wl-clipboard
    xclip
  ];
}
