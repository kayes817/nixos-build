{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bluez
    python3Packages.bleak
    bluewalker
    redfang
    ubertooth
  ];
}
