{ pkgs, inputs, ... }:
let
  hackpkgsPackages =
    if inputs ? hackpkgs
      && inputs.hackpkgs ? packages
      && builtins.hasAttr pkgs.system inputs.hackpkgs.packages
    then pkgs.lib.mapAttrsToList (_: v: v) inputs.hackpkgs.packages.${pkgs.system}
    else [];
in
{
  environment.systemPackages = hackpkgsPackages;
}
