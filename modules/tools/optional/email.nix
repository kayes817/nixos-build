{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mx-takeover
    ruler
    swaks
    trustymail
  ];
}
