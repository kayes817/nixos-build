{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sammler
    gosh
    godspeed
    snowcrash
  ];
}
