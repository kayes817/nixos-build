{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ares-rs
    badchars
    changetower
    creds
    doona
    galleta
    honeytrap
    jwt-cli
    kepler
    nmap-formatter
    python3Packages.pytenable
    snscrape
    sr2t
    sttr
    troubadix
  ];
}
