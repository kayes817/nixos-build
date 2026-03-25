{ pkgs, ... }:
let
  optionalPkg = path:
    let
      pkg = pkgs.lib.attrByPath path null pkgs;
    in
      pkgs.lib.optional (pkg != null) pkg;

  optionalPkgs = paths: builtins.concatLists (map optionalPkg paths);
in
{
  environment.systemPackages =
    (with pkgs; [
      adidnsdump
      adreaper
      breads-ad
      certi
      certipy
      certsync
      coercer
      donpapi
      enum4linux
      erosmb
      go365
      gomapenum
      knowsmore
      lil-pwny
      nbtscan
      nbtscanner
      offensive-azure
      python3Packages.lsassy
      python3Packages.pypykatz
      rdwatool
      smbmap
      smbscan
    ])
    ++ optionalPkgs [
      [ "python3Packages" "impacket" ]
    ];
}
