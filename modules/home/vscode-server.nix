{ pkgs, flake, ... }:
{
  imports = [
    "${flake.inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
  ];

  home.shellAliases = {
    "gcode" = "code";
  };

  services.vscode-server.enable = true;
  # services.vscode-server.installPath = "~/.vscode-server-insiders";
}
