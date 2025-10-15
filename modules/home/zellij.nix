{ pkgs, lib, config, ... }:

let


  layouts = {
    dev = ''
      layout {
        pane size=1 borderless=true {
          plugin location="zellij:tab-bar"
        }
        pane split_direction="vertical" {
          pane {
            command "${pkgs.zsh}/bin/zsh"
          }
        }
        pane size=1 borderless=true {
          plugin location="zellij:status-bar"
        }
      };
    '';
  };

  # Convert layouts attrset -> xdg.configFile entries
  layoutConfigFiles =
    lib.mapAttrs' (name: content: {
      name = "zellij/layouts/${name}.kdl";
      value = { text = content; };
    }) layouts;
in
{
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;              # Override if you want a patched build
    enableZshIntegration = true;
    enableBashIntegration = true;
    # enableFishIntegration = true;



    # If you want to provide an entire manual config file instead of settings:
    # configFile = ./my-full-config.kdl;

    # Keybinding map (only a small sample; extend as needed)


    settings = {
      # Optional additional WASM plugins (placeholders)
      plugins = [ ];


      # Theme selection (built‑in or one you define below)
      theme = "custom-dracula";
      default_shell = "${pkgs.zsh}/bin/zsh";
      default_layout = "dev";         # Must match a name in defaultLayouts
      pane_frames = true;
      mouse_mode = true;
      simplified_ui = false;
      scrollback_lines = 20000;
      copy_command =
        if pkgs.stdenv.isLinux then "wl-copy" else "pbcopy";
      mirror_session = false;
      session_serialization = true;
      disable_automatic_rename = false;
      display_tab_numbers = true;
      on_force_close = "quit";        # (quit|detach)
      # Example: plugin search paths (if you add external WASM)
      plugin_dirs = [ "${pkgs.zellij}/share/zellij/plugins" ];

      # Custom theme definition
      themes.custom-dracula = {
        fg = [ 248 248 242 ];
        bg = [ 40 42 54 ];
        black = [ 0 0 0 ];
        red = [ 255 85 85 ];
        green = [ 80 250 123 ];
        yellow = [ 241 250 140 ];
        blue = [ 98 114 164 ];
        magenta = [ 255 121 198 ];
        cyan = [ 139 233 253 ];
        white = [ 255 255 255 ];
        orange = [ 255 184 108 ];
      };

      # Another minimal theme example
      themes.minimal = {
        fg = [ 230 230 230 ];
        bg = [ 20 20 20 ];
        black = [ 20 20 20 ];
        red = [ 220 50 47 ];
        green = [ 133 153 0 ];
        yellow = [ 181 137 0 ];
        blue = [ 38 139 210 ];
        magenta = [ 211 54 130 ];
        cyan = [ 42 161 152 ];
        white = [ 238 232 213 ];
        orange = [ 203 75 22 ];
      };

    };
  };

 # Materialize layout files under ~/.config/zellij/layouts/
  xdg.configFile = layoutConfigFiles;

  # Suggest ensuring clipboard utilities exist
  home.packages = lib.mkAfter (
    lib.optional pkgs.stdenv.isLinux pkgs.wl-clipboard
  );
}
