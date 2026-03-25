{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    teler
    waf-tester
    wafw00f
  ];
}
