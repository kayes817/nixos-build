{ pkgs, ... }:
let
  mod = "Mod4";
  bg = "#2e3440";
  mantle = "#3b4252";
  surface0 = "#434c5e";
  surface1 = "#4c566a";
  text = "#eceff4";
  subtext = "#d8dee9";
  blue = "#88c0d0";
  pink = "#b48ead";
  red = "#bf616a";
  teal = "#8fbcbb";
  wallpaper = ../../assets/wallpapers/desktop.png;
  statusScript = pkgs.writeShellScript "i3-status-minimal" ''
    printf '{ "version": 1 }\n[\n[]\n'

    while true; do
      root_avail="$(${pkgs.coreutils}/bin/df -h / | ${pkgs.gawk}/bin/awk 'NR==2 {print $4}')"
      mem_used_mib="$(${pkgs.procps}/bin/free -m | ${pkgs.gawk}/bin/awk '/^Mem:/ {print $3}')"
      mem_total_mib="$(${pkgs.procps}/bin/free -m | ${pkgs.gawk}/bin/awk '/^Mem:/ {print $2}')"
      mem_used_gib="$(${pkgs.gawk}/bin/awk "BEGIN {printf \"%.1f\", $mem_used_mib/1024}")"
      mem_total_gib="$(${pkgs.gawk}/bin/awk "BEGIN {printf \"%.1f\", $mem_total_mib/1024}")"
      host_ip="$(${pkgs.iproute2}/bin/ip route get 1.1.1.1 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP 'src \K\S+' | ${pkgs.coreutils}/bin/head -n1)"
      tailscale_ip="$(${pkgs.iproute2}/bin/ip -4 addr show dev tailscale0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP 'inet \K[0-9.]+' | ${pkgs.coreutils}/bin/head -n1)"
      now="$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M')"

      if [ -z "$host_ip" ]; then
        host_ip="offline"
      fi

      if [ -z "$tailscale_ip" ]; then
        tailscale_ip="down"
      fi

      printf ',[\n'
      printf '  {"full_text":"LAN %s","color":"#88c0d0"},\n' "$host_ip"
      printf '  {"full_text":"TS %s","color":"#8fbcbb"},\n' "$tailscale_ip"
      printf '  {"full_text":"RAM %s/%s GiB","color":"#eceff4"},\n' "$mem_used_gib" "$mem_total_gib"
      printf '  {"full_text":"Disk %s free","color":"#d8dee9"},\n' "$root_avail"
      printf '  {"full_text":"%s","color":"#eceff4"}\n' "$now"
      printf ']\n'
      sleep 5
    done
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
    background = "${bg}"
    foreground = "${text}"

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
  terminal = "${pkgs.alacritty}/bin/alacritty --config-file ${alacrittyConfig}";
  rofiTheme = pkgs.writeText "rofi-nord.rasi" ''
    configuration {
      modi: "drun,run,window";
      show-icons: true;
      display-drun: "Apps";
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
      bg: ${bg};
      bg-alt: ${mantle};
      fg: ${text};
      fg-alt: ${subtext};
      accent: ${blue};
      accent-2: ${teal};
      urgent: ${red};
      selected: ${surface0};
      border: ${blue};
      border-radius: 8px;
      font: "JetBrainsMono Nerd Font 12";
    }

    window {
      width: 38%;
      padding: 16px;
      border: 1px;
      border-color: @border;
      border-radius: @border-radius;
      background-color: @bg;
    }

    mainbox {
      spacing: 12px;
      background-color: transparent;
    }

    inputbar {
      padding: 10px 12px;
      border: 0 0 1px 0;
      border-color: @accent;
      background-color: @bg-alt;
      text-color: @fg;
    }

    prompt {
      text-color: @accent;
      children: [ prompt, textbox-prompt-colon, entry ];
    }

    textbox-prompt-colon {
      text-color: @accent;
    }

    entry {
      background-color: transparent;
      text-color: @fg;
      placeholder: "Search apps, commands, and windows";
      placeholder-color: @fg-alt;
    }

    listview {
      lines: 8;
      columns: 1;
      spacing: 6px;
      scrollbar: false;
      background-color: transparent;
    }

    element {
      padding: 10px 12px;
      border: 0;
      border-radius: 6px;
      background-color: transparent;
      text-color: @fg;
    }

    element selected {
      background-color: @selected;
      text-color: @fg;
    }

    element-icon {
      size: 22px;
      margin: 0 10px 0 0;
    }
  '';
  picomConf = pkgs.writeText "picom-nord.conf" ''
    backend = "xrender";
    corner-radius = 0;
    round-borders = 0;
    shadow = true;
    shadow-radius = 14;
    shadow-opacity = 0.18;
    shadow-offset-x = -8;
    shadow-offset-y = -8;
    shadow-color = "${blue}";
    fading = true;
    fade-delta = 5;
    fade-in-step = 0.08;
    fade-out-step = 0.08;
    inactive-opacity = 0.92;
    active-opacity = 1.0;
    frame-opacity = 1.0;
    inactive-dim = 0.06;
  '';
  launcher = "${pkgs.rofi}/bin/rofi -show drun -theme ${rofiTheme} -show-icons -drun-match-fields name,generic,exec,categories,keywords -drun-display-format '{name}' -matching fuzzy -sort";
  browser = "${pkgs.brave}/bin/brave";
  fileManager = "${pkgs.thunar}/bin/thunar";
  lockCmd = "${pkgs.i3lock-color}/bin/i3lock-color -c 2e3440 --ring-color 88c0d0ff --keyhl-color 8fbcbbff --bshl-color bf616aff --inside-color 2e3440cc --separator-color 00000000 --line-color 00000000 --ringver-color 81a1c1ff --insidever-color 2e3440cc --ringwrong-color bf616aff --insidewrong-color 2e3440cc --verif-color eceff4ff --wrong-color eceff4ff --time-color 88c0d0ff --date-color 81a1c1ff --layout-color eceff4ff";
  i3Config = pkgs.writeText "i3-config" ''
    set $mod ${mod}
    font pango:JetBrainsMono Nerd Font 11

    floating_modifier $mod
    default_border pixel 2
    default_floating_border pixel 2
    gaps inner 10
    gaps outer 4

    bindsym $mod+Return exec ${terminal}
    bindsym $mod+d exec --no-startup-id ${launcher}
    bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit this i3 session?' -B 'Log out' 'i3-msg exit'"
    bindsym $mod+Shift+r restart
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+q kill
    bindsym $mod+q kill
    bindsym $mod+Shift+f exec ${browser}
    bindsym $mod+e exec ${fileManager}
    bindsym $mod+Shift+Return exec ${terminal} --class floating-term
    bindsym $mod+Ctrl+l exec ${lockCmd}
    bindsym Print exec ${pkgs.scrot}/bin/scrot -e 'mv $f ~/Pictures/'
    bindsym Shift+Print exec ${pkgs.scrot}/bin/scrot -s -e 'mv $f ~/Pictures/'
    bindsym XF86AudioRaiseVolume exec ${pkgs.pamixer}/bin/pamixer -i 5
    bindsym XF86AudioLowerVolume exec ${pkgs.pamixer}/bin/pamixer -d 5
    bindsym XF86AudioMute exec ${pkgs.pamixer}/bin/pamixer -t
    bindsym XF86AudioMicMute exec ${pkgs.pamixer}/bin/pamixer --default-source -t
    bindsym XF86MonBrightnessUp exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%
    bindsym XF86MonBrightnessDown exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-

    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right

    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right

    bindsym $mod+v split v
    bindsym $mod+b split h
    bindsym $mod+f fullscreen toggle
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+Shift+s sticky toggle
    bindsym $mod+a focus parent
    bindsym $mod+r mode "resize"
    bindsym $mod+Shift+space floating toggle, move position center
    bindsym $mod+space focus mode_toggle
    bindsym $mod+Tab workspace back_and_forth
    bindsym $mod+Shift+minus move scratchpad
    bindsym $mod+minus scratchpad show

    set $ws1 "1:web"
    set $ws2 "2:term"
    set $ws3 "3:code"
    set $ws4 "4:files"
    set $ws5 "5:chat"
    set $ws6 "6:media"
    set $ws7 "7"
    set $ws8 "8"
    set $ws9 "9"
    set $ws10 "10"

    bindsym $mod+1 workspace $ws1
    bindsym $mod+2 workspace $ws2
    bindsym $mod+3 workspace $ws3
    bindsym $mod+4 workspace $ws4
    bindsym $mod+5 workspace $ws5
    bindsym $mod+6 workspace $ws6
    bindsym $mod+7 workspace $ws7
    bindsym $mod+8 workspace $ws8
    bindsym $mod+9 workspace $ws9
    bindsym $mod+0 workspace $ws10

    bindsym $mod+Shift+1 move container to workspace $ws1
    bindsym $mod+Shift+2 move container to workspace $ws2
    bindsym $mod+Shift+3 move container to workspace $ws3
    bindsym $mod+Shift+4 move container to workspace $ws4
    bindsym $mod+Shift+5 move container to workspace $ws5
    bindsym $mod+Shift+6 move container to workspace $ws6
    bindsym $mod+Shift+7 move container to workspace $ws7
    bindsym $mod+Shift+8 move container to workspace $ws8
    bindsym $mod+Shift+9 move container to workspace $ws9
    bindsym $mod+Shift+0 move container to workspace $ws10
    bindsym $mod+Shift+v floating enable, resize set 1366 768, move position center
    bindsym $mod+Shift+m floating enable, move position center
    bindsym $mod+Ctrl+h move left 40 px
    bindsym $mod+Ctrl+j move down 40 px
    bindsym $mod+Ctrl+k move up 40 px
    bindsym $mod+Ctrl+l move right 40 px

    mode "resize" {
      bindsym h resize shrink width 10 px or 10 ppt
      bindsym j resize grow height 10 px or 10 ppt
      bindsym k resize shrink height 10 px or 10 ppt
      bindsym l resize grow width 10 px or 10 ppt

      bindsym Left resize shrink width 10 px or 10 ppt
      bindsym Down resize grow height 10 px or 10 ppt
      bindsym Up resize shrink height 10 px or 10 ppt
      bindsym Right resize grow width 10 px or 10 ppt

      bindsym Return mode "default"
      bindsym Escape mode "default"
      bindsym $mod+r mode "default"
    }

    bar {
      status_command ${statusScript}
      position top
      tray_output primary
      colors {
        background ${bg}
        statusline ${text}
        separator ${surface1}
        focused_workspace  ${blue} ${blue} ${bg}
        active_workspace   ${surface0} ${surface0} ${text}
        inactive_workspace ${bg} ${bg} ${subtext}
        urgent_workspace   ${red} ${red} ${bg}
      }
    }

    exec_always --no-startup-id ${pkgs.feh}/bin/feh --bg-fill ${wallpaper}
    exec --no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet
    exec --no-startup-id ${pkgs.pasystray}/bin/pasystray
    exec --no-startup-id ${pkgs.dunst}/bin/dunst
    exec --no-startup-id ${pkgs.picom}/bin/picom --config ${picomConf}
    exec --no-startup-id ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    exec --no-startup-id ${pkgs.thunar}/bin/thunar --daemon

    for_window [class="floating-term"] floating enable, resize set 1100 720, move position center
    for_window [window_role="pop-up"] floating enable
    for_window [window_type="dialog"] floating enable
    for_window [window_type="utility"] floating enable
    for_window [window_type="toolbar"] floating enable
    for_window [window_type="splash"] floating enable
    mouse_warping none

    client.focused          ${blue} ${blue} ${bg} ${blue} ${blue}
    client.focused_inactive ${surface0} ${surface0} ${text} ${surface0} ${surface0}
    client.unfocused        ${bg} ${bg} ${subtext} ${bg} ${bg}
    client.urgent           ${red} ${red} ${bg} ${red} ${red}
  '';
in
{
  services.xserver.enable = true;
  services.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    iconTheme.name = "Adwaita";
    cursorTheme.name = "Adwaita";
    indicators = [
      "~session"
      "~spacer"
      "~clock"
      "~spacer"
      "~power"
    ];
    clock-format = "%a %b %d  %H:%M";
    extraConfig = ''
      background=${wallpaper}
      theme-name=Adwaita-dark
      icon-theme-name=Adwaita
      cursor-theme-name=Adwaita
      font-name=JetBrainsMono Nerd Font 11
      xft-antialias=true
      xft-hintstyle=hintslight
      xft-rgba=rgb
      hide-user-image=true
      default-user-image=#000000
    '';
  };
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu
      i3status
      i3lock-color
      rofi
    ];
    configFile = i3Config;
  };

  services.libinput.enable = true;
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

  security.polkit.enable = true;
  security.rtkit.enable = true;

  hardware.graphics.enable = true;

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

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";

  environment.variables = {
    BROWSER = "brave";
    TERMINAL = "alacritty";
  };

  environment.systemPackages = with pkgs; [
    alacritty
    adwaita-icon-theme
    brightnessctl
    dunst
    feh
    brave
    gnome-themes-extra
    pamixer
    scrot
    jq
    networkmanagerapplet
    pavucontrol
    pasystray
    picom
    playerctl
    polkit_gnome
    rofi
    unzip
    xclip
    thunar
    thunar-volman
    zip
  ];
}
