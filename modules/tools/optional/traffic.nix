{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    anevicon
    dhcpdump
    dnstop
    driftnet
    dsniff
    goreplay
    httpdump
    joincap
    junkie
    netsniff-ng
    ngrep
    secrets-extractor
    sniffglue
    tcpdump
    tcpflow
    tcpreplay
    termshark
    python3Packages.pyshark
    wireshark
    wireshark-cli
  ];
}
