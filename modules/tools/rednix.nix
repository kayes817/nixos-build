{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    burpsuite
    ffuf
    gobuster
    hashcat
    httpx
    john
    masscan
    naabu
    nmap
    nuclei
    nuclei-templates
    rustscan
    seclists
    sqlmap
    tcpdump
    testssl
    whatweb
    wireshark
    wireshark-cli
  ];
}
