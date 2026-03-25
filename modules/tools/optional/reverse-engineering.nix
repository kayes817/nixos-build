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
      bingrep
      flare-floss
      gdb
      ghidra-bin
      ioc-scan
      bytecode-viewer
      mono
      pev
      pwndbg
      python3Packages.karton-core
      python3Packages.malduck
      python3Packages.r2pipe
      python3Packages.unicorn
      radare2
      rizin
      stacks
      unicorn
      valgrind
      volatility3
      xortool
      yara
      zkar
      zydis
    ])
    ++ optionalPkgs [
      [ "jadx" ]
      [ "jd-cli" ]
    ];
}
