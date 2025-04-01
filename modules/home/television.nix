{ pkgs, ... }:
{
  programs.zsh = {
    # FIXME: doesn't work (macos)
    initExtra = ''

      _tv_smart_autocomplete() {
          emulate -L zsh
          zle -I

          local current_prompt
          current_prompt=$LBUFFER

          local output

          output=$(tv --autocomplete-prompt "$current_prompt" $*)


          if [[ -n $output ]]; then
              zle reset-prompt
              RBUFFER=""
              # add a space if the prompt does not end with one
              [[ "''${current_prompt}" != *" " ]] && current_prompt="''${current_prompt} "
              LBUFFER=$current_prompt$output

              # uncomment this to automatically accept the line
              # (i.e. run the command without having to press enter twice)
              # zle accept-line
          fi
      }

      _tv_shell_history() {
          emulate -L zsh
          zle -I

          local current_prompt
          current_prompt=$LBUFFER

          local output

          output=$(tv zsh-history --input "$current_prompt" $*)


          if [[ -n $output ]]; then
              zle reset-prompt
              RBUFFER=""
              LBUFFER=$output

              # uncomment this to automatically accept the line
              # (i.e. run the command without having to press enter twice)
              # zle accept-line
          fi
      }


      zle -N tv-smart-autocomplete _tv_smart_autocomplete
      zle -N tv-shell-history _tv_shell_history


      bindkey '^T' tv-smart-autocomplete
      # bindkey '^R' tv-shell-history
    '';
  };

  home.file.".config/television/default_channels.toml" = {
    recursive = true;
    text = ''
      # GIT
      [[cable_channel]]
      name = "git-diff"
      source_command = "git diff --name-only"
      preview_command = "git diff --color=always {0}"

      [[cable_channel]]
      name = "git-reflog"
      source_command = 'git reflog'
      preview_command = 'git show -p --stat --pretty=fuller --color=always {0}'

      [[cable_channel]]
      name = "git-log"
      source_command = "git log --oneline --date=short --pretty=\"format:%h %s %an %cd\" \"$@\""
      preview_command = "git show -p --stat --pretty=fuller --color=always {0}"

      [[cable_channel]]
      name = "git-branch"
      source_command = "git --no-pager branch --all --format=\"%(refname:short)\""
      preview_command = "git show -p --stat --pretty=fuller --color=always {0}"

      # Docker
      [[cable_channel]]
      name = "docker-images"
      source_command = "docker image list --format \"{{.ID}}\""
      preview_command = "docker image inspect {0} | jq -C"

      # S3
      [[cable_channel]]
      name = "s3-buckets"
      source_command = "aws s3 ls | cut -d \" \" -f 3"
      preview_command = "aws s3 ls s3://{0}"

      # Dotfiles
      [[cable_channel]]
      name = "my-dotfiles"
      source_command = "fd -t f . $HOME/.config"
      preview_command = ":files:"

      # Shell history
      [[cable_channel]]
      name = "zsh-history"
      source_command = "sed '1!G;h;$!d' $HOME/.zsh_history | cut -d\";\" -f 2-"

      [[cable_channel]]
      name = "bash-history"
      source_command = "sed '1!G;h;$!d' $HOME/.bash_history"

      [[cable_channel]]
      name = "fish-history"
      source_command = "fish -c 'history'"

      [[cable_channel]]
      name = "task"
      source_command = "task rc.defaultwidth:500 rc.defaultheight:1000"
      preview_command = "task $(echo {} | awk '/([0-9])/{ print $1 }')"

      [[cable_channel]]
      name = "git-reflog"
      source_command = 'git reflog'
      preview_command = 'git show -p --stat --pretty=fuller --color=always {0}'
    '';
  };

  home.file.".config/television/config.toml" = {
    recursive = true;
    text = ''
      # CONFIGURATION FILE LOCATION ON YOUR SYSTEM:
      # -------------------------------------------
      # Defaults:
      # ---------
      #  Linux:   `$HOME/.config/television/config.toml`
      #  macOS:   `$HOME/.config/television/config.toml`
      #  Windows: `%APPDATA%\television\config.toml`
      #
      # XDG dirs:
      # ---------
      # You may use XDG_CONFIG_HOME if set on your system.
      # In that case, television will expect the configuration file to be in:
      # `$XDG_CONFIG_HOME/television/config.toml`
      #

      # General settings
      # ----------------------------------------------------------------------------
      frame_rate = 60 # DEPRECATED: this option is no longer used
      tick_rate = 50

      [ui]
      # Whether to use nerd font icons in the UI
      # This option requires a font patched with Nerd Font in order to properly
      # display glyphs (see https://www.nerdfonts.com/ for more information)
      use_nerd_font_icons = false
      # How much space to allocate for the UI (in percentage of the screen)
      # ┌───────────────────────────────────────┐
      # │                                       │
      # │            Terminal screen            │
      # │    ┌─────────────────────────────┐    │
      # │    │                             │    │
      # │    │                             │    │
      # │    │                             │    │
      # │    │       Television UI         │    │
      # │    │                             │    │
      # │    │                             │    │
      # │    │                             │    │
      # │    │                             │    │
      # │    └─────────────────────────────┘    │
      # │                                       │
      # │                                       │
      # └───────────────────────────────────────┘
      ui_scale = 100
      # Whether to show the top help bar in the UI by default
      # This option can be toggled with the (default) `ctrl-g` keybinding
      show_help_bar = false
      # Whether to show the preview panel in the UI by default
      # This option can be toggled with the (default) `ctrl-o` keybinding
      show_preview_panel = true
      # Where to place the input bar in the UI (top or bottom)
      input_bar_position = "top"
      # DEPRECATED: title is now always displayed at the top as part of the border
      # Where to place the preview title in the UI (top or bottom)
      # preview_title_position = "top"
      # The theme to use for the UI
      # A list of builtin themes can be found in the `themes` directory of the television
      # repository. You may also create your own theme by creating a new file in a `themes`
      # directory in your configuration directory (see the `config.toml` location above).
      theme = "default"

      # Previewers settings
      # ----------------------------------------------------------------------------
      [previewers.file]
      # The theme to use for syntax highlighting.
      # Bulitin syntax highlighting uses the same syntax highlighting engine as bat.
      # To get a list of your currently available themes, run `bat --list-themes`
      # Note that setting the BAT_THEME environment variable will override this setting.
      theme = "TwoDark"

      # Keybindings
      # ----------------------------------------------------------------------------
      #
      # Channel mode
      # ------------------------
      [keybindings.Channel]
      # Quit the application
      quit = ["esc", "ctrl-c"]
      # Scrolling through entries
      select_next_entry = ["down", "ctrl-n", "ctrl-j"]
      select_prev_entry = ["up", "ctrl-p", "ctrl-k"]
      select_next_page = "pagedown"
      select_prev_page = "pageup"
      # Scrolling the preview pane
      scroll_preview_half_page_down = "ctrl-d"
      scroll_preview_half_page_up = "ctrl-u"
      # Add entry to selection and move to the next entry
      toggle_selection_down = "tab"
      # Add entry to selection and move to the previous entry
      toggle_selection_up = "backtab"
      # Confirm selection
      confirm_selection = "enter"
      # Copy the selected entry to the clipboard
      copy_entry_to_clipboard = "ctrl-y"
      # Toggle the remote control mode
      toggle_remote_control = "ctrl-r"
      # Toggle the send to channel mode
      toggle_send_to_channel = "ctrl-s"
      # Toggle the help bar
      toggle_help = "ctrl-g"
      # Toggle the preview panel
      toggle_preview = "ctrl-o"


      # Remote control mode
      # -------------------------------
      [keybindings.RemoteControl]
      # Quit the application
      quit = "esc"
      # Scrolling through entries
      select_next_entry = ["down", "ctrl-n", "ctrl-j"]
      select_prev_entry = ["up", "ctrl-p", "ctrl-k"]
      select_next_page = "pagedown"
      select_prev_page = "pageup"
      # Select an entry
      select_entry = "enter"
      # Toggle the remote control mode
      toggle_remote_control = "ctrl-r"
      # Toggle the help bar
      toggle_help = "ctrl-g"
      # Toggle the preview panel
      toggle_preview = "ctrl-o"


      # Send to channel mode
      # --------------------------------
      [keybindings.SendToChannel]
      # Quit the application
      quit = "esc"
      # Scrolling through entries
      select_next_entry = ["down", "ctrl-n", "ctrl-j"]
      select_prev_entry = ["up", "ctrl-p", "ctrl-k"]
      select_next_page = "pagedown"
      select_prev_page = "pageup"
      # Select an entry
      select_entry = "enter"
      # Toggle the send to channel mode
      toggle_send_to_channel = "ctrl-s"
      # Toggle the help bar
      toggle_help = "ctrl-g"
      # Toggle the preview panel
      toggle_preview = "ctrl-o"


      # Shell integration
      # ----------------------------------------------------------------------------
      #
      # The shell integration feature allows you to use television as a picker for
      # your shell commands (as well as your shell history with <CTRL-R>).
      # E.g. typing `git checkout <CTRL-T>` will open television with a list of
      # branches to choose from.

      [shell_integration.commands]
      # Add your commands here. Each key is a command that will trigger tv with the
      # corresponding channel as value.
      # Example: say you want the following prompts to trigger the following channels
      # when pressing <CTRL-T>:
      #          `git checkout` should trigger the `git-branches` channel
      #          `ls`           should trigger the `dirs` channel
      #          `cat`          should trigger the `files` channel
      #
      # You would add the following to your configuration file:
      # ```
      # [shell_integration.commands]
      # "git checkout" = "git-branch"
      # "ls" = "dirs"
      # "cat" = "files"
      # ```

      # environment variables
      "export" = "env"
      "unset" = "env"

      # dirs channel
      "cd" = "dirs"
      "ls" = "dirs"
      "rmdir" = "dirs"

      # files channel
      "cat" = "files"
      "less" = "files"
      "head" = "files"
      "tail" = "files"
      "vim" = "files"
      "bat" = "files"
      "code" = "files"

      # git-diff channel
      "git add" = "git-diff"

      # git-branch channel
      "git checkout" = "git-branch"
      "git branch -d" = "git-branch"

      # docker-images channel
      "docker run" = "docker-images"

      "git reflog" = "git-reflog"

      # gitrepos channel
      "nvim" = "git-repos"

      "task" = "task"

      [shell_integration.keybindings]
      # controls which key binding should trigger tv
      # for shell autocomplete
      "smart_autocomplete" = "ctrl-t"
      # controls which keybinding should trigger tv
      # for command history
      "command_history" = "ctrl-r"
    '';
  };

  home.packages = with pkgs; [ television ];
}
