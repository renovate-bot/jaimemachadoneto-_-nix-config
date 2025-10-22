{ config, ... }:

let
  # Use the shared SOPS helper functions
  inherit (config._sopsHelpers) mkSopsSecret mkSopsSecrets;

  # Define secrets for jaime user
  mySecrets = mkSopsSecrets [
    (mkSopsSecret {
      secretPath = "keys/atuin";
      envVar = "ATUIN_KEY";
      filePath = "${config.home.homeDirectory}/.local/share/atuin/key";
    })
    # (mkSopsSecret {
    #   secretPath = "keys/khomelab/kubeconfig";
    #   envVar = "KUBECONFIG";
    #   filePath = "${config.home.homeDirectory}/.kube/config";
    # })

    # Add more secrets as needed:
    # (mkSopsSecret {
    #   secretPath = "keys/work-token";
    #   envVar = "WORK_API_TOKEN";
    # })
  ];

in {
  imports = [
    ../common/home
  ];

  home.username = "jaime";

  # Apply the secrets configuration
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
