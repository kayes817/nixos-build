{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    oshka
  ];
}
