# { pkgs, inputs, ... }: {
#   # imports = [ "${inputs._1password-shell-plugins}/nix/home-manager.nix" ];

#   # programs._1password-shell-plugins = {
#   #   # enable 1Password shell plugins for bash, zsh, and fish shell
#   #   enable = true;
#   #   # the specified packages as well as 1Password CLI will be
#   #   # automatically installed and configured to use shell plugins
#   #   plugins = with pkgs; [ gh awscli2 cachix ];
#   # };


#   home.packages = [
#     pkgs._1password
#     pkgs._1password-gui
#     pkgs._1password-cli
#   ];
# }
{ pkgs, inputs, config, lib, ... }:
let
  cfg = config._1password; # or whatever namespace you prefer
in
{
  options._1password = {
    enable = lib.mkEnableOption "1Password packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs._1password
      pkgs._1password-gui
      pkgs._1password-cli
    ];
  };
}
