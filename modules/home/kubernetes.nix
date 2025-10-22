{ pkgs, config, ... }:
{
  sops.secrets."${config.host.kubernetesSoapsSecretPath}" = {
    path = "${config.home.homeDirectory}/.kube/config";
  };
}
