{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    arduino
    cantoolz
    chipsec
    cmospwd
    esptool
    extrude
    gallia
    hachoir
    teensy-loader-cli
    python3Packages.python-can
    python3Packages.pyi2cflash
    python3Packages.pyspiflash
  ];
}
