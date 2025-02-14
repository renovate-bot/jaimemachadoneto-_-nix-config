{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "`";
    shell = "${pkgs.zsh}/bin/zsh";

    historyLimit = 20000;
    clock24 = false;
    keyMode = "emacs";
    tmuxinator.enable = true;
    terminal = "tmux-256color";
    mouse = true;
    sensibleOnTop = true;
    # # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    newSession = true;
    # # Stop tmux+escape craziness.
    escapeTime = 50;
    # # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;

    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      extrakto
      yank
      fuzzback
      # menus
      # 1password
      # suspend
      # mode-indicator
      {
        plugin = dracula;
        extraConfig = ''
          # available plugins: battery, cpu-usage, git, gpu-usage, ram-usage, network, network-bandwidth, network-ping, weather, time
          set -g @dracula-plugins "cpu-usage git ram-usage network-bandwidth wheather time" #, git, gpu-usage, ram-usage, network, network-bandwidth, network-ping, weather, time"
          set -g @dracula-fixed-location "Barcelona"
          set -g @dracula-show-fahrenheit false
          set -g @dracula-ping-server "8.8.8.8"
          set -g @net_speed_interfaces "eth0"
          set -g @dracula-show-powerline true
          set -g @dracula-show-flags true
          set -g @dracula-show-battery false
          set -g @dracula-refresh-rate 10
        '';
      }
      copy-toolkit
      fingers
      resurrect
      continuum
      sidebar
    ];

    extraConfig = ''
      set -g automatic-rename 1
      # Automatically set window title
      set -g automatic-rename-format " #I:#{=30:pane_title}#F "
      set -g status-right " %H:%M %d-%b-%y"
      # Reset title formats
      set -g set-titles on
      set -g set-titles-string "#h:#S:#{pane_title} #{session_alerts}"

      # set -g set-titles-string "#T"

      # set-window-option -g automatic-rename off
      # set-option -g set-titles off
      # set -g set-titles-string "#I:#W"

      # Split panes
      bind | split-window -h -c "#{pane_current_path}"
      bind _ split-window -v -c "#{pane_current_path}"
      # Select pane and windows
      bind -r C-[ previous-window
      bind -r C-] next-window
      #bind -r [ select-pane -t :.-
      #bind -r ] select-pane -t :.+

      # Terminal settings
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",*:RGB"
      set -ag terminal-overrides ",*:Tc"
      set -as terminal-features ",*:RGB"


      # Other settings
      setw -g automatic-rename off
      set-window-option -g automatic-rename off
      set-option -g set-titles off
      set -g set-titles-string "#I:#W"


      # Rename session and window
      bind -r r      command-prompt -I W "rename-window '%%'"
      bind -r R      command-prompt 'rename-session %%'

      # Split panes
      bind | split-window -h -c "#{pane_current_path}"
      bind _ split-window -v -c "#{pane_current_path}"
      # Select pane and windows
      bind -r C-[ previous-window
      bind -r C-] next-window

      bind -r Tab last-window   # cycle thru MRU tabs
      bind -r C-o swap-pane -D

      # Rename session and window
      bind -r r      command-prompt -I W "rename-window '%%'"
      bind -r R      command-prompt 'rename-session %%'

      # Smart pane switching with awareness of vim splits
      is_vim_emacs='echo "#{pane_current_command}" | \
          grep -iqE "((^|\/)g?(view|n?vim?x?)(diff)?$)|emacs|emacsclient"'

      # enable in root key table
      bind -n 'M-l' if-shell "$is_vim_emacs" "send-keys M-l" "select-pane -L"
      bind -n 'M-k' if-shell "$is_vim_emacs" "send-keys M-k" "select-pane -D"
      bind -n 'M-i' if-shell "$is_vim_emacs" "send-keys M-i" "select-pane -U"
      bind -n 'M-j' if-shell "$is_vim_emacs" "send-keys M-j" "select-pane -R"
      bind -n 'M-\' if-shell "$is_vim_emacs" "send-keys M-\\\\" "select-pane -l"

      # enable in copy mode key table
      bind -Tcopy-mode-vi 'M-l' if-shell "$is_vim_emacs" "send-keys M-l" "select-pane -L"
      bind -Tcopy-mode-vi 'M-k' if-shell "$is_vim_emacs" "send-keys M-k" "select-pane -D"
      bind -Tcopy-mode-vi 'M-i' if-shell "$is_vim_emacs" "send-keys M-i" "select-pane -U"
      bind -Tcopy-mode-vi 'M-j' if-shell "$is_vim_emacs" "send-keys M-j" "select-pane -R"
      bind -Tcopy-mode-vi 'M-\' if-shell "$is_vim_emacs" "send-keys M-\\\\" "select-pane -l"

      bind -r Escape copy-mode

      # new window and retain cwd
      bind c new-window -c "#{pane_current_path}"

      # Full vioset -g mode-keys emacs
      set -g status-keys emacs
      #bind-key -Tcopy-mode-vi 'v' send -X begin-selection
      #bind-key -Tcopy-mode-vi 'y' send -X copy-selection
      bind-key Escape copy-mode

      # Focus events enabled for terminals that support them
      set -g focus-events on

      # Open %% man page
      bind C-m command-prompt -p "Open man page for:" "new-window 'exec man %%'"

      bind-key C-k send-keys C-l \; clear-history

      # Zoom pane
      bind -n M-o resize-pane -Z
      bind + resize-pane -Z

      set-window-option -g xterm-keys on

      # Open %% man page
      bind C-m command-prompt -p "Open man page for:" "new-window 'exec man %%'"

      # Enable status bar
      bind-key b set-option status

      # Update window index
      set-option -g renumber-windows on

      setw -g monitor-activity on

      # tmux-extractor
      set -g @extrakto_key [

      # better-mouse config
      set -g @emulate-scroll-for-no-mouse-alternate-buffer "off"

      #fuzzy back config
      set -g @fuzzback-bind >

      set -g @suspend_key 'F12'

      # set the pane border colors
      set -g pane-border-style 'fg=colour235,bg=colour238'
      set -g pane-active-border-style 'fg=colour51,bg=colour236'

      set -g mode-keys emacs
      set -g status-keys emacs

      setw -g mouse on
      set -g set-clipboard on
      #  bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -se c -i"
      bind-key -n Home send Escape "OH"
      bind-key -n End send Escape "OF"

    '';
  };

  programs.tmate = {
    enable = true;
    # FIXME: This causes tmate to hang.
    # extraConfig = config.xdg.configFile."tmux/tmux.conf".text;
  };

  home.packages = [
    # Open tmux for current project.
    (pkgs.writeShellApplication {
      name = "pux";
      runtimeInputs = [ pkgs.tmux ];
      text = ''
        PRJ="''$(zoxide query -i)"
        echo "Launching tmux for ''$PRJ"
        set -x
        cd "''$PRJ" && \
          exec tmux -S "''$PRJ".tmux attach
      '';
    })
  ];
}
