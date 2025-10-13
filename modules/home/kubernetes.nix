{ pkgs, config, ... }:

let
  kubernetesSoapsSecretPath = config.kubernetesSoapsSecretPath;
in
{
  sops.secrets."${config.kubernetesSoapsSecretPath}" = {
    path = "${config.home.homeDirectory}/.kube/config";
  };
}
