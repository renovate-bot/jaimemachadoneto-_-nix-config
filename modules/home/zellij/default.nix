{ pkgs, lib, ... }:

let
  # External keybindings file (keep your original KDL here)
  keybindingsFile = ./keybindings.kdl;


  # Read all *.kdl files under ./layouts and deploy them to ~/.config/zellij/layouts/
  layoutsDir = ./layouts;
  layoutFileNames =
    builtins.filter (f: lib.hasSuffix ".kdl" f)
      (builtins.attrNames (builtins.readDir layoutsDir));

  layoutConfigFiles =
    builtins.listToAttrs (map (f: {
      name = "zellij/layouts/${lib.removeSuffix ".kdl" f}.kdl";
      value = { text = builtins.readFile (layoutsDir + "/${f}"); };
    }) layoutFileNames);

  # Read all regular files under ./plugins and deploy them to ~/.config/zellij/plugins/
  pluginsDir = ./plugins;
  pluginFileNames =
    builtins.filter (f: (builtins.readDir pluginsDir).${f} == "regular")
      (builtins.attrNames (builtins.readDir pluginsDir));

  pluginConfigFiles =
    builtins.listToAttrs (map (f: {
      name = "zellij/plugins/${f}";
      value.source = pluginsDir + "/${f}";
    }) pluginFileNames);


  keybindsText = builtins.readFile keybindingsFile;

  baseConfig = ''
    // Choose what to do when zellij receives SIGTERM, SIGINT, SIGQUIT or SIGHUP
    // eg. when terminal window with an active zellij session is closed
    // Options:
    //   - detach (Default)
    //   - quit
    //
    // on_force_close "quit"

    // Send a request for a simplified ui (without arrow fonts) to plugins
    // Options:
    //   - true
    //   - false (Default)
    //
    // simplified_ui true

    // Choose the path to the default shell that zellij will use for opening new panes
    // Default: $SHELL
    //
    default_shell "${pkgs.zsh}/bin/zsh"

    // Toggle between having pane frames around the panes
    // Options:
    //   - true (default)
    //   - false
    //
    // pane_frames true

    // Choose the theme that is specified in the themes section.
    // Default: default
    //
    theme "tokyo_night"

    // The name of the default layout to load on startup
    // Default: "default"
    //
    default_layout "work"

    // Choose the mode that zellij uses when starting up.
    // Default: normal
    //
    // default_mode "locked"

    // Toggle enabling the mouse mode.
    // On certain configurations, or terminals this could
    // potentially interfere with copying text.
    // Options:
    //   - true (default)
    //   - false
    //
    // mouse_mode false

    // Configure the scroll back buffer size
    // This is the number of lines zellij stores for each pane in the scroll back
    // buffer. Excess number of lines are discarded in a FIFO fashion.
    // Valid values: positive integers
    // Default value: 10000
    //
    // scroll_buffer_size 10000

    // Provide a command to execute when copying text. The text will be piped to
    // the stdin of the program to perform the copy. This can be used with
    // terminal emulators which do not support the OSC 52 ANSI control sequence
    // that will be used by default if this option is not set.
    // Examples:
    //
    // copy_command "xclip -selection clipboard" // x11
    // copy_command "wl-copy"                    // wayland
    // copy_command "pbcopy"                     // osx
    copy_command "${if pkgs.stdenv.isLinux then "wl-copy" else "pbcopy"}"

    // Choose the destination for copied text
    // Allows using the primary selection buffer (on x11/wayland) instead of the system clipboard.
    // Does not apply when using copy_command.
    // Options:
    //   - system (default)
    //   - primary
    //
    // copy_clipboard "primary"

    // Enable or disable automatic copy (and clear) of selection when releasing mouse
    // Default: true
    //
    // copy_on_select false

    // Path to the default editor to use to edit pane scrollbuffer
    // Default: $EDITOR or $VISUAL
    //
    //scrollback_editor "/usr/bin/micro"

    // When attaching to an existing session with other users,
    // should the session be mirrored (true)
    // or should each user have their own cursor (false)
    // Default: false
    //
    // mirror_session true

    // The folder in which Zellij will look for layouts
    //
    // layout_dir /path/to/my/layout_dir

    // The folder in which Zellij will look for themes
    //
    // theme_dir "/path/to/my/theme_dir"

    plugins {
      tab-bar { path "tab-bar"; }
      status-bar { path "status-bar"; }
      strider { path "strider"; }
      compact-bar { path "compact-bar"; }
      session-manager { path "session-manager"; }
    }

    ui {
        pane_frames {
            rounded_corners true
        }
    }


    themes {
      catppuccin-latte {
        fg 172 176 190
        bg 172 176 190
        black 220 224 232
        red 210 15 57
        green 64 160 43
        yellow 223 142 29
        blue 30 102 245
        magenta 234 118 203
        cyan 4 165 229
        white 76 79 105
        orange 254 100 11
      }
      catppuccin-frappe {
        fg 198 208 245
        bg 98 104 128
        black 41 44 60
        red 231 130 132
        green 166 209 137
        yellow 229 200 144
        blue 140 170 238
        magenta 244 184 228
        cyan 153 209 219
        white 198 208 245
        orange 239 159 118
      }
      catppuccin-macchiato {
        fg 202 211 245
        bg 91 96 120
        black 30 32 48
        red 237 135 150
        green 166 218 149
        yellow 238 212 159
        blue 138 173 244
        magenta 245 189 230
        cyan 145 215 227
        white 202 211 245
        orange 245 169 127
      }
      catppuccin-mocha {
        fg 205 214 244
        bg 88 91 112
        black 24 24 37
        red 243 139 168
        green 166 227 161
        yellow 249 226 175
        blue 137 180 250
        magenta 245 194 231
        cyan 137 220 235
        white 205 214 244
        orange 250 179 135
      }
      tokyo_night {
        fg 169 177 214
        bg 26 27 38
        black 56 62 90
        red 249 51 87
        green 158 206 106
        yellow 224 175 104
        blue 122 162 247
        magenta 187 154 247
        cyan 42 195 222
        white 192 202 245
        orange 255 158 100
      }
    }
  '';

  fullConfig = baseConfig + "\n" + keybindsText;
in
{
  # Only basic options (manual config file approach)
  programs.zellij.enable = false;
  programs.zellij.package = pkgs.zellij;
  programs.zellij.enableZshIntegration = true;
  programs.zellij.enableBashIntegration = true;

  # Deploy config + layouts + plugins
  xdg.configFile =
    layoutConfigFiles
    // pluginConfigFiles
    // {
      "zellij/config.kdl".text = fullConfig;
    };

  # Clipboard helper
  home.packages = lib.mkAfter (lib.optional pkgs.stdenv.isLinux pkgs.wl-clipboard);
}
