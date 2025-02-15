{ flake, hostSpec, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # inherit hostSpec;
  imports = [
    ./jaime

  ];
  #  flake.config.hostSpec.hostName = "jaime-note";
  # home.username = flake.config.hostSpec.username;

}
