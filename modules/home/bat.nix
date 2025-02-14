{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "dracula";
      style = "full,-grid";
    };

    extraPackages = with pkgs.bat-extras; [
      batgrep # search through and highlight files using ripgrep
      batdiff # Diff a file against the current git index, or display the diff between to files
      batman # read manpages using bat as the formatter
      batwatch # Watch a file and run bat whenever it changes
    ];
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
  # Avoid [bat error]: The binary caches for the user-customized syntaxes and themes in
  # '/home/<user>/.cache/bat' are not compatible with this version of bat (0.25.0).
  home.activation.batCacheRebuild = {
    after = [ "linkGeneration" ];
    before = [ ];
    data = ''
      ${pkgs.bat}/bin/bat cache --build
    '';
  };
}
