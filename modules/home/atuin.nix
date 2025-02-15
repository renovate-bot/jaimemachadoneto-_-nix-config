{ config, flake, ... }: {
  # sops.secrets.atuin_secret = {
  #   path = "/home/${flake.config.me.username}/.config/atuin/atuin_secret";
  # };


  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      sync_address = "https://atuin.machadoneto.win";
      sync_frequency = "5m";
      auto_sync = true;
      dialect = "us";
      search_mode = "fuzzy";
      store_failed = true;
      secrets_filter = true;
      keymap_mode = "emacs";
      style = "auto";
      # key_path = config.sops.secrets."keys/atuin".path; #"/run/secrets/atuin_secret";
      common_subcommands = [
        "apt"
        "cargo"
        "composer"
        "dnf"
        "docker"
        "git"
        "go"
        "ip"
        "kubectl"
        "nix"
        "nmcli"
        "npm"
        "pecl"
        "pnpm"
        "podman"
        "port"
        "systemctl"
        "tmux"
        "yarn"
        "nix"
      ];
    };
  };
}
