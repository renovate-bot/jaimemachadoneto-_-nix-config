{ lib, flake ? null, ... }:
let
  # Get the hostname from environment, fallback to kernel hostname if empty
  hostname =
    let
      envHostname = builtins.getEnv "HOSTNAME";
      envHostname2 = builtins.getEnv "NAME";
      envHostname3 = builtins.getEnv "HOST";
    in
    if envHostname2 != ""
    then envHostname2
    else if envHostname != ""
    then envHostname
    else if envHostname3 != ""
    then envHostname3
    else builtins.getEnv "NIXOS_HOSTNAME";

  # # Default host configuration
  # defaultHostConfig = {
  #   host = {
  #     isWSL = builtins.getEnv "WSL_DISTRO_NAME" != "";
  #     windowsUser = "";
  #     windowsGitPath = "";
  #     gitEmail = "jaime.machado@gmail.com";
  #     gitName = "Jaime Machado Neto";
  #   };
  # };

  # Try to load host-specific config from nix-secrets, fallback to default if it doesn't exist
  hostOverrides =
    if flake != null && builtins.pathExists "${flake.inputs.nix-secrets}/hosts/${hostname}.nix"
    then (import "${flake.inputs.nix-secrets}/hosts/${hostname}.nix").host or { }
    else { };
in
{
  options = {
    host = {
      isWSL = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "WSL detection from host-specific configuration";
      };
      windowsUser = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Windows user name for WSL";
      };
      windowsGitPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Windows Git path for WSL";
      };

      gitEmail = lib.mkOption {
        type = lib.types.str;
        default = "jaime.machado@gmail.com";
        description = "Git email for commits";
      };
      gitName = lib.mkOption {
        type = lib.types.str;
        default = "Jaime Machado Neto";
        description = "Git user name for commits";
      };
    };
  };

  config = {
    host = hostOverrides;
  };
}
