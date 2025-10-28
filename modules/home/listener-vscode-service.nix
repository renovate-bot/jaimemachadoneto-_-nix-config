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
    systemd.user.services.remote-vscode-listener = {
      Install = {
        WantedBy = [ "default.target" ];
      };
      Unit = {
        After = "network.target";
        Description = "Remote VS Code Listener Service";
      };
      Service = {
        ExecStart = "${pkgs.listener-code}/bin/listener-code";
        Restart = "always"; # Restart the service if it crashes
        RestartSec = 5; # Wait 5 seconds before restarting
        StandardOutput = "journal"; # Log output to the journal
        StandardError = "journal"; # Log errors to the journal
      };
    };
  };
}
