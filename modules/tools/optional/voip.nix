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
      sipp
      sipsak
      sipvicious
      sngrep
    ])
    ++ optionalPkgs [
      [ "siparmyknife" ]
    ];
}
