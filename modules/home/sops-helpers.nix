{ lib, config, ... }:

let
  # Helper function to create SOPS secret with environment variables
  mkSopsSecret = {
    secretPath,           # SOPS path like "keys/atuin"
    envVar,              # Environment variable name(s) - string or list of strings
    filePath ? null,     # Optional custom file path
    mode ? "0400",       # File permissions
    createPathVar ? true # Whether to create a *_PATH variable
  }:
  let
    # Default file path based on secret path
    defaultPath = "${config.home.homeDirectory}/.local/share/secrets/${builtins.replaceStrings ["/"] ["-"] secretPath}";
    actualPath = if filePath != null then filePath else defaultPath;
    
    # Handle both single string and list of strings for envVar
    envVarList = if builtins.isList envVar then envVar else [ envVar ];
    
    # Create PATH variables for each envVar (if enabled)
    pathVars = lib.listToAttrs (lib.flatten (map (var:
      lib.optional createPathVar {
        name = "${var}_PATH";
        value = actualPath;
      }
    ) envVarList));
    
    # Create shell initialization for all environment variables
    shellInitLines = map (var: ''
      # Load ${secretPath} secret content into ${var}
      if [[ -f "${actualPath}" ]]; then
        export ${var}="$(cat ${actualPath})"
      fi'') envVarList;
      
  in {
    # SOPS secret configuration
    sopsSecret = {
      ${secretPath} = {
        path = actualPath;
        inherit mode;
      };
    };

    # Session variables for file paths (optional)
    sessionVar = pathVars;

    # Shell initialization for content
    shellInit = lib.concatStringsSep "\n      " shellInitLines;
  };

  # Helper function to merge multiple secrets
  mkSopsSecrets = secrets:
    let
      sopsSecrets = lib.foldl' (acc: secret: acc // secret.sopsSecret) {} secrets;
      sessionVars = lib.foldl' (acc: secret: acc // secret.sessionVar) {} secrets;
      shellInits = lib.concatStringsSep "\n    " (map (secret: secret.shellInit) secrets);
    in {
      sops.secrets = sopsSecrets;
      home.sessionVariables = sessionVars;
      shellInit = shellInits;
    };

in {
  # Export the helper functions for use in other modules
  options._sopsHelpers = lib.mkOption {
    type = lib.types.attrs;
    default = {
      inherit mkSopsSecret mkSopsSecrets;
    };
    description = "Helper functions for SOPS secrets management";
    internal = true;
  };

  config._sopsHelpers = {
    inherit mkSopsSecret mkSopsSecrets;
  };
}
