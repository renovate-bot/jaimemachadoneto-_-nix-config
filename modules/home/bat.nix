{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "dracula";
      style = "full,-grid";
    };

    extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
    themes = {
      dracula = {
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "sublime"; # Bat uses sublime syntax for its themes
          rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
          sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
        };
        file = "Dracula.tmTheme";
      };
    };

  };
  home.shellAliases = {
    "c" = "bat --theme=\"Dracula\" --style='full,-grid' --paging=never";
  };
}
