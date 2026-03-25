{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cutecom
    minicom
    picocom
    socat
    x3270
    tmate
    screen
    tmux
    zellij
  ];
}
