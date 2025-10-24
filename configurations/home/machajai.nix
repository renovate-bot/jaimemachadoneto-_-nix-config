{ config, lib, pkgs, ... }:

let
  # Use the shared helper functions
  inherit (config._sopsHelpers) mkSopsSecret mkSopsSecrets;

  # Define your secrets using the helper function
  mySecrets = mkSopsSecrets [
    (mkSopsSecret {
      secretPath = "keys/atuin";
      envVar = "ATUIN_KEY";
      filePath = "${config.home.homeDirectory}/.local/share/atuin/key";
    })
    (mkSopsSecret {
      secretPath = "keys/hp/github-token/machajai";
      envVar = "ghe_auth_token";
      filePath = "${config.home.homeDirectory}/.config/github/token";
    })
    # Add more secrets easily:
    # (mkSopsSecret {
    #   secretPath = "api/openai";
    #   envVar = "OPENAI_API_KEY";
    # })

    # Multiple environment variables from same secret
    # (mkSopsSecret {
    #   secretPath = "database/postgres";
    #   envVar = [ "DATABASE_URL" "POSTGRES_URL" "DB_URL" ];
    #   createPathVar = false;  # Don't create *_PATH variables
    # })

    # GitHub token with multiple aliases
    # (mkSopsSecret {
    #   secretPath = "api/github";
    #   envVar = [ "GITHUB_TOKEN" "GH_TOKEN" "GITHUB_API_KEY" ];
    # })

    # SSH key
    # (mkSopsSecret {
    #   secretPath = "ssh/deploy-key";
    #   envVar = "DEPLOY_SSH_KEY";
    #   filePath = "${config.home.homeDirectory}/.ssh/deploy_key";
    #   mode = "0600";
    # })
  ];

in {
  imports = [
    ../common/home
  ];

  home.username = "machajai";
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/machajai";

  # Apply the secrets configuration using helper function
  inherit (mySecrets) sops;
  home.sessionVariables = mySecrets.home.sessionVariables;

  # Shell initialization to load secret content into environment variables
  programs.zsh.initExtra = ''
    ${mySecrets.shellInit}
  '';

  programs.bash.initExtra = ''
    ${mySecrets.shellInit}
  '';

}
