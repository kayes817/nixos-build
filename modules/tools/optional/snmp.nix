{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    braa
    onesixtyone
    snmpcheck
  ];
}
