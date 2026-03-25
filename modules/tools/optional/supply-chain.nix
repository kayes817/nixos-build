{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    chain-bench
    witness
  ];
}
