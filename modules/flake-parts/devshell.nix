{ inputs, ... }:
{
  imports = [
    (inputs.git-hooks + /flake-module.nix)
  ];
  perSystem = { pkgs, config, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixos-config-shell";
      meta.description = "Shell environment for modifying this Nix configuration";
      inputsFrom = [ config.pre-commit.devShell ];
      packages = with pkgs; [
        go-task
        nixd
        nix-output-monitor
      ];
    };
    pre-commit.settings = {
      hooks.nixpkgs-fmt.enable = true;
    };
  };
}
