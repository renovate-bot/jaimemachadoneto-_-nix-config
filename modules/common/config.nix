{ lib, flake ? null, ... }:
let
  # Get the hostname from environment, fallback to kernel hostname if empty
  hostname =
    let envHostname = builtins.getEnv "HOSTNAME";
    in if envHostname != ""
    then envHostname
    else builtins.elemAt (builtins.match "([^\n]*)\n.*" (builtins.readFile "/etc/hostname")) 0;

  # Try to load host-specific config from nix-secrets, fallback to default if it doesn't exist
  hostConfig =
    if flake != null && builtins.pathExists "${flake.inputs.nix-secrets}/hosts/${hostname}.nix"
    then import "${flake.inputs.nix-secrets}/hosts/${hostname}.nix"
    else if flake != null && builtins.pathExists "${flake.inputs.nix-secrets}/hosts/default.nix"
    then import "${flake.inputs.nix-secrets}/hosts/default.nix"
    else { host.isWSL = builtins.getEnv "WSL_DISTRO_NAME" != ""; };
in
{
  options = {
    hostConfig.isWSL = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "WSL detection from host-specific configuration";
    };
    hostConfig.windowsUser = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Windows user name for WSL";
    };
    hostConfig.windowsGitPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Windows Git path for WSL";
    };
  };

  config = {
    hostConfig.isWSL = lib.mkDefault (
      (hostConfig.host or { }).isWSL or (builtins.getEnv "WSL_DISTRO_NAME" != "")
    );
    hostConfig.windowsUser = lib.mkDefault (
      (hostConfig.windowsUser or { }).windowsUser or builtins.getEnv "USER"
    );
    hostConfig.windowsGitPath = lib.mkDefault (
      (hostConfig.windowsGitPath or { }).windowsGitPath or builtins.getEnv "GIT_PATH"
    );
  };
}
