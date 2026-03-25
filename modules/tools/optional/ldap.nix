{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3Packages.ldapdomaindump
    adenum
    hekatomb
    msldapdump
    ldapmonitor
    ldapdomaindump
    ldapnomnom
    ldeep
    silenthound
  ];
}
