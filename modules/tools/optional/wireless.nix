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
      aircrack-ng
      airgeddon
      bully
      cowpatty
      dbmonster
      horst
      killerbee
      kismet
      pixiewps
      reaverwps
      reaverwps-t6x
      wavemon
      wifite2
      gqrx
      kalibrate-hackrf
      kalibrate-rtl
      multimon-ng
    ])
    ++ optionalPkgs [
      [ "hackrf" ]
      [ "rtl-sdr" ]
      [ "uhd" ]
      [ "gnu-radio" ]
      [ "inspectrum" ]
    ];
}
