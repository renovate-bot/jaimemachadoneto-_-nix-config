{ flake, pkgs, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  # inherit hostSpec;
in
{

  imports = [
    ../../modules/common/config.nix
    self.homeModules.default

  ];

  #  flake.config.hostSpec.hostName = "jaime-note";
  # home.username = flake.config.hostSpec.username;
  config.hostSpec.username = "jaime";
  config.hostSpec.hostName = "jaime-note";
  config.hostSpec.domain = inputs.nix-secrets.secrets.domain;
  config.hostSpec.userFullName = inputs.nix-secrets.secrets.userFullName;
  config.hostSpec.handle = inputs.nix-secrets.secrets.handle;
  config.hostSpec.email = inputs.nix-secrets.secrets.email;
  config.hostSpec.work.email = inputs.nix-secrets.secrets.email.work;


  # To use the `nix` from `inputs.nixpkgs` on templates using the standalone `home-manager` template

  # `nix.package` is already set if on `NixOS` or `nix-darwin`.
  # TODO: Avoid setting `nix.package` in two places. Does https://github.com/juspay/nixos-unified-template/issues/93 help here?
  nix.package = lib.mkDefault pkgs.nix;
  home.packages = [
    config.nix.package
  ];

  home.username = config.hostSpec.username;
  # home.username = flake.config.hostSpec.username;
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.hostSpec.username}";
  home.stateVersion = "24.11";

}
