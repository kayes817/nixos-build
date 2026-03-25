{ lib, pkgs, self, ... }:
{
  imports =
    [
      self.nixosModules.default
      /etc/nixos/hardware-configuration.nix
    ]
    ++ lib.optional (builtins.pathExists ./local.nix) ./local.nix;

  networking.hostName = "nixos";

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.r48817 = {
    isNormalUser = true;
    description = "r48817";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  system.stateVersion = "25.11";
}
