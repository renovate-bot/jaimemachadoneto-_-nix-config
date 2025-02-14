{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.noto-fonts
    pkgs.nerd-fonts.sauce-code-pro
    pkgs.meslo-lgs-nf
  ];
}
