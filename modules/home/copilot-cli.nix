{ pkgs, config, ... }:

let
  copilotSecretPath = "${config.home.homeDirectory}/.local/share/secrets/keys-copilot";

  copilotWithEnv = pkgs.copilot.override {
    envVars = {
      GITHUB_TOKEN = {
        fromFile = copilotSecretPath;
      };
    };
  };
in
{
  sops.secrets."keys/copilot".path = copilotSecretPath;

  home.packages = [ copilotWithEnv ];
}
