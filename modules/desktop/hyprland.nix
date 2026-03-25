{ pkgs, ... }:
let
  fallbackHyprConfig = pkgs.writeText "hyprland-fallback.conf" ''
    $mod = SUPER
    $terminal = ${pkgs.alacritty}/bin/alacritty
    $browser = ${pkgs.brave}/bin/brave
    $fileManager = ${pkgs.thunar}/bin/thunar
    $menu = ${pkgs.rofi}/bin/rofi -show drun
    $lock = ${pkgs.swaylock}/bin/swaylock --color 232733

    monitor = ,preferred,auto,1

    env = XCURSOR_THEME,Adwaita
    env = XCURSOR_SIZE,24
    env = HYPRCURSOR_THEME,Adwaita
    env = HYPRCURSOR_SIZE,24
    env = NIXOS_OZONE_WL,1
    env = WLR_NO_HARDWARE_CURSORS,1
    env = WLR_RENDERER_ALLOW_SOFTWARE,1
    env = LIBGL_ALWAYS_SOFTWARE,1

    exec-once = ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
    exec-once = ${pkgs.dunst}/bin/dunst
    exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1

    input {
      kb_layout = us
      follow_mouse = 1
    }

    general {
      gaps_in = 8
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
      inactive_opacity = 0.96
    }

    animations {
      enabled = true
      animation = windows, 1, 5, default
      animation = fade, 1, 4, default
      animation = workspaces, 1, 4, default
    }

    dwindle {
      pseudotile = true
      preserve_split = true
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }

    bind = $mod, Return, exec, $terminal
    bind = $mod SHIFT, Return, exec, $terminal
    bind = $mod, D, exec, $menu
    bind = $mod, B, exec, $browser
    bind = $mod, E, exec, $fileManager
    bind = $mod ALT, L, exec, $lock
    bind = $mod, Q, killactive,
    bind = $mod SHIFT, Q, exit,
    bind = $mod SHIFT, C, exec, ${pkgs.hyprland}/bin/hyprctl reload

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

    bind = $mod, F, fullscreen, 0
    bind = $mod SHIFT, SPACE, togglefloating,
    bind = $mod, SPACE, cyclenext
    bind = $mod, TAB, workspace, previous

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
  '';

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

  environment.etc."xdg/hypr/hyprland.conf".source = fallbackHyprConfig;

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    alacritty
    brave
    brightnessctl
    dunst
    grim
    imagemagick
    jq
    networkmanagerapplet
    pamixer
    pasystray
    playerctl
    polkit_gnome
    rofi
    slurp
    stow
    swaybg
    swaylock
    thunar
    thunar-volman
    waybar
    wl-clipboard
    xclip
  ];
}
