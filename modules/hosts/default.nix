{ lib, pkgs, self, ... }:
let
  zshInit = ''
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

  programs.zsh = {
    enable = true;
    interactiveShellInit = zshInit;
  };

  systemd.services.random-hostname = {
    description = "Generate persistent random node hostname";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" ];
    before = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      state_dir=/var/lib/random-hostname
      state_file=$state_dir/hostname

      mkdir -p "$state_dir"

      if [ ! -f "$state_file" ]; then
        num="$(tr -dc '0-9' < /dev/urandom | head -c 6)"
        echo "node-$num" > "$state_file"
      fi

      hostname="$(cat "$state_file")"
      ${pkgs.hostname}/bin/hostnamectl set-hostname "$hostname"
    '';
  };

  system.stateVersion = "25.11";
}
