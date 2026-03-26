{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core CLI
    curl
    git
    htop
    wget

    # Files and search
    eza
    fd
    ripgrep

    # Archives
    unzip
    zip

    # Programming
    python315
    nodejs

    # IDE
    vscode
    opencode

    # Chat
    discord

    # Containers
    docker
    docker-compose

    # Notes
    obsidian

    # Video
    vlc

    # Photo
    gimp

    # VPNs
    tailscale
    openvpn

    # Remote access
    remmina
  ];
}
