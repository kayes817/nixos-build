{ lib, pkgs, self, ... }:
let
  userZshrc = pkgs.writeText "r48817-zshrc" ''
    export EDITOR=nvim
    export VISUAL=nvim

    setopt AUTO_CD
    setopt HIST_IGNORE_DUPS
    setopt SHARE_HISTORY

    HISTSIZE=5000
    SAVEHIST=5000
    HISTFILE=$HOME/.zsh_history
    WORDCHARS=""

    autoload -Uz compinit
    compinit

    if [[ -o interactive ]] && [[ -z "$ZSH_ASCII_SHOWN" ]]; then
      export ZSH_ASCII_SHOWN=1
      cat <<'EOF'
  (\(\ 
  ( -.-)
  o_(")(")      
EOF
      echo
    fi

    bindkey -e
    bindkey '^[[1;5D' backward-word
    bindkey '^[[1;5C' forward-word
    bindkey '^[[5D' backward-word
    bindkey '^[[5C' forward-word
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word
    bindkey '^[[H' beginning-of-line
    bindkey '^[[F' end-of-line
    bindkey '^[[1~' beginning-of-line
    bindkey '^[[4~' end-of-line
    bindkey '^[[7~' beginning-of-line
    bindkey '^[[8~' end-of-line
    PROMPT='%F{81}%n@%m%f:%F{110}%~%f %# '
  '';
in {
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

  system.activationScripts.r48817-zshrc = {
    text = ''
      install -D -m 0644 -o r48817 -g users ${userZshrc} /home/r48817/.zshrc
    '';
  };

  system.stateVersion = "25.11";
}
