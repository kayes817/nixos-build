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
      cardpeek
      libfreefare
      mfcuk
      mfoc
      python3Packages.emv
    ])
    ++ optionalPkgs [
      [ "libnfc" ]
      [ "nfcutils" ]
    ];
}
