{ pkgs, flake, ... }:
{
  imports = [
    "${flake.inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
  ];

  home.shellAliases = {
    "gcode" = "code";
    "grcode" = "rcode";
  };
  home.packages = with pkgs; [
    rcode
  ];


  #TODO: Disable due to issue https://github.com/nix-community/nixos-vscode-server/issues/90
  services.vscode-server.enable = false;
  # services.vscode-server.installPath = "~/.vscode-server-insiders";
}
