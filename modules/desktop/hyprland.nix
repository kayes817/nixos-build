{ pkgs, ... }:
let
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
