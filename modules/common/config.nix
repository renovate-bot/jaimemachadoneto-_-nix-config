{ lib, flake ? null, ... }:
let
  # Get the hostname from environment, fallback to kernel hostname if empty
  hostname =
    let
      envHostname = builtins.getEnv "HOSTNAME";
      envHostname2 = builtins.getEnv "NAME";
      envHostname3 = builtins.getEnv "HOST";
    in if envHostname2 != ""
    then envHostname2
    else if envHostname != ""
    then envHostname
    else if envHostname3 != ""
    then envHostname3
    else builtins.getEnv "NIXOS_HOSTNAME";

  # Try to load host-specific config from nix-secrets, fallback to default if it doesn't exist
  hostConfig =
    if builtins.pathExists "${flake.inputs.nix-secrets}/hosts/${hostname}.nix"
    then import "${flake.inputs.nix-secrets}/hosts/${hostname}.nix"
    # else if flake != null && builtins.pathExists "${flake.inputs.nix-secrets}/hosts/default.nix"
    # then import "${flake.inputs.nix-secrets}/hosts/default.nix"
    else { host.isWSL = builtins.getEnv "WSL_DISTRO_NAME" != ""; };
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
    };
  };

  config = {
    host = {
      isWSL = lib.mkDefault (
        hostConfig.host.isWSL or (builtins.getEnv "WSL_DISTRO_NAME" != "")
      );
      windowsUser = lib.mkDefault (
        hostConfig.host.windowsUser or (builtins.getEnv "USER")
      );
      windowsGitPath = lib.mkDefault (
        hostConfig.host.windowsGitPath
      );
    };
  };
}
