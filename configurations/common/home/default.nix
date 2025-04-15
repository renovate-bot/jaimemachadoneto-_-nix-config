{ flake, pkgs, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    ../../../config.nix
  ];

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

  # Nix configuration
  nix.package = lib.mkDefault pkgs.nix;
  home.packages = [
    config.nix.package
  ];

  # Common state version
  home.stateVersion = "24.11";

  # Common system settings
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}";
}
