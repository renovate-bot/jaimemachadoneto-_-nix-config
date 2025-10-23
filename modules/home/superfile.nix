{ pkgs, config, ... }:
{
  programs.superfile = {
    enable = true;
  };
  home.shellAliases.sf = "superfile";
}
