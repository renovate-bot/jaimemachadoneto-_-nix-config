{ lib, config, pkgs, ... }:

let
  cfg = config.remote-vscode-listener;
in
{
  options.remote-vscode-listener = {
    enable = lib.mkEnableOption "Enable remote-vscode-listener";
  };

  config = lib.mkIf cfg.enable {
    # Enable the systemd service for the user
    # systemd.user.services.remote-vscode-listener = {
    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    #   Unit = {
    #     After = "network.target";
    #     Description = "Remote VS Code Listener Service";
    #   };
    #   Service = {
    #     ExecStart = "${pkgs.listener-code}/bin/listener-code";
    #     Restart = "always"; # Restart the service if it crashes
    #     RestartSec = 5; # Wait 5 seconds before restarting
    #     StandardOutput = "journal"; # Log output to the journal
    #     StandardError = "journal"; # Log errors to the journal

    #     # Load environment variables from the dynamically created file
    #     EnvironmentFile = "%h/.config/environment.d/wsl-env.conf";
    #     # Pass WSL-related environment variables

    #     PassEnvironment = ["PATH" "WSL_INTEROP" "WSLENV" "DISPLAY" "WIN_HOME" "TEMP" "TMP" "PWD" "WSL_DISTRO_NAME" "WSL2"];
    #   };
    # };

    #     # Create the environment file dynamically
    # home.file.".config/environment.d/wsl-env.conf" = {
    #   text = ''
    #     PATH=$PATH
    #     WSL_INTEROP=$WSL_INTEROP
    #     WSLENV=$WSLENV
    #     DISPLAY=$DISPLAY
    #     WIN_HOME=$HOME
    #     TEMP=$TEMP
    #     TMP=$TMP
    #     PWD=$PWD
    #     WSL_DISTRO_NAME=$WSL_DISTRO_NAME
    #     WSL2=$WSL2
    #   '';
    #   # permissions = "0644"; # Ensure the file is readable
    # };
  };
}
