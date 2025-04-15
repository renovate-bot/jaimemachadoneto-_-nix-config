{ lib, ... }:
let
  # Import the values from the Nix file
  values = import ./system-values.nix;
in
{
  options = {
    hostConfig.isWSL = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "WSL detection from configuration";
    };
  };

  config = {
    hostConfig.isWSL = lib.mkDefault (
      if builtins.pathExists ./system-values.nix
      then values.host.isWSL or (builtins.getEnv "WSL_DISTRO_NAME" != "")
      else builtins.getEnv "WSL_DISTRO_NAME" != ""
    );
  };
}
