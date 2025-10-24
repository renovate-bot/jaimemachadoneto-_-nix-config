{ pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;
    # Note: More defined in juspay.nix
    matchBlocks = {
      "*" = {
        setEnv = {
          # https://ghostty.org/docs/help/terminfo#configure-ssh-to-fall-back-to-a-known-terminfo-entry
          TERM = "xterm-256color";
        };
        addKeysToAgent = "yes";
      };
      pureintent = {
        forwardAgent = true;
      };
    };
  };

  home.packages = with pkgs; [ autossh ];
  home.shellAliases = {
    "openTunnel" = "autossh -M 0 -fN -R 8000:localhost:22 $USER@10.30.5.3";
  };

  services.ssh-agent = lib.mkIf pkgs.stdenv.isLinux { enable = true; };
}
