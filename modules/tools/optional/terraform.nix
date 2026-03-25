{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    terrascan
    tfsec
  ];
}
