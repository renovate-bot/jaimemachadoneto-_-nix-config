{ flake, pkgs, ... }:
{
  # imports = [
  #   flake.inputs.nixvim.homeManagerModules.nixvim
  #   flake.inputs.nvix.packages.${pkgs.system}.default
  # ];


  home.packages = with pkgs; [
    # flake.inputs.nixvim.packages.${pkgs.system}.default
    # flake.inputs.nixvim.packages.${pkgs.system}.nixvim
    flake.inputs.nvix.packages.${pkgs.system}.core
  ];

  # programs.nixvim = {import ./nixvim.nix // {
  # programs.nixvim = {
  #   enable = true;
  #   imports = [

  #   ];

  #   # colorschemes.catppuccin.enable = lib.mkForce false;
  #   # colorschemes.nord.enable = true;
  # };
}
