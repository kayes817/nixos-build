{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cloud-nuke
    cloudfox
    ec2stepshell
    gato
    gcp-scanner
    goblob
    imdshift
    pacu
    prowler
    yatas
  ];
}
