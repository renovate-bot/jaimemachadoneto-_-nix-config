{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super: {
  copy-md-as-html = self.callPackage "${packages}/copy-md-as-html.nix" { };
}
