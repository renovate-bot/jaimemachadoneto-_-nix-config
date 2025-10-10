# SOPS Helpers Usage Guide

The SOPS helpers module provides easy-to-use functions for managing secrets across all home configurations.

## Location

- **Module**: `modules/home/sops-helpers.nix`
- **Imported in**: `configurations/common/home/default.nix`
- **Available in**: All home configurations

## Usage in any home configuration

```nix
{ config, ... }:

let
  # Import the helper functions
  inherit (config._sopsHelpers) mkSopsSecret mkSopsSecrets;

  # Define your secrets
  mySecrets = mkSopsSecrets [
    (mkSopsSecret {
      secretPath = "keys/atuin";
      envVar = "ATUIN_KEY";
      filePath = "${config.home.homeDirectory}/.local/share/atuin/key";
    })
    (mkSopsSecret {
      secretPath = "api/github";
      envVar = "GITHUB_TOKEN";
    })
    # Multiple environment variables from same secret
    (mkSopsSecret {
      secretPath = "database/credentials";
      envVar = [ "DB_PASSWORD" "DATABASE_PASSWORD" "POSTGRES_PASSWORD" ];
    })
  ];

in {
  imports = [ ../common/home ];

  home.username = "your-username";

  # Apply secrets configuration
  inherit (mySecrets) sops;
  home.sessionVariables = mySecrets.home.sessionVariables;

  # Shell initialization
  programs.zsh.initExtra = ''
    ${mySecrets.shellInit}
  '';

  programs.bash.initExtra = ''
    ${mySecrets.shellInit}
  '';
}
```

## Function Reference

### `mkSopsSecret`

Creates a single SOPS secret with environment variables.

**Parameters:**

- `secretPath` (string, required): Path in SOPS file (e.g., "keys/atuin")
- `envVar` (string or list, required): Environment variable name(s) - can be single string or list of strings
- `filePath` (string, optional): Custom file path (defaults to ~/.local/share/secrets/...)
- `mode` (string, optional): File permissions (defaults to "0400")
- `createPathVar` (bool, optional): Create \*\_PATH variable (defaults to true)

**Example:**

```nix
(mkSopsSecret {
  secretPath = "database/postgres";
  envVar = "DATABASE_URL";
  filePath = "${config.home.homeDirectory}/.config/db/url";
  mode = "0600";
  createPathVar = false;
})
```

**Creates:**

- `sops.secrets."database/postgres"` pointing to the file
- `DATABASE_URL` environment variable with secret content
- No `DATABASE_URL_PATH` (since `createPathVar = false`)

### `mkSopsSecrets`

Merges multiple secrets into a single configuration.

**Parameters:**

- `secrets` (list): List of secrets created with `mkSopsSecret`

**Returns:**

- `sops.secrets`: All SOPS secret definitions
- `home.sessionVariables`: All \*\_PATH environment variables
- `shellInit`: Shell code to load all secret contents

## Examples

### Simple API Token

```nix
(mkSopsSecret {
  secretPath = "api/openai";
  envVar = "OPENAI_API_KEY";
})
```

### SSH Key with Custom Path

```nix
(mkSopsSecret {
  secretPath = "ssh/deploy-key";
  envVar = "DEPLOY_SSH_KEY";
  filePath = "${config.home.homeDirectory}/.ssh/deploy_key";
  mode = "0600";
})
```

### Database URL (no PATH variable)

```nix
(mkSopsSecret {
  secretPath = "database/postgres";
  envVar = "DATABASE_URL";
  createPathVar = false;
})
```

### Multiple Environment Variables from Same Secret

```nix
(mkSopsSecret {
  secretPath = "database/credentials";
  envVar = [ "DB_PASSWORD" "DATABASE_PASSWORD" "POSTGRES_PASSWORD" ];
})
```

This creates:

- One secret file with the database password
- Three environment variables (`DB_PASSWORD`, `DATABASE_PASSWORD`, `POSTGRES_PASSWORD`) all containing the same secret
- Three PATH variables (`DB_PASSWORD_PATH`, `DATABASE_PASSWORD_PATH`, `POSTGRES_PASSWORD_PATH`)

### API Token with Multiple Aliases

```nix
(mkSopsSecret {
  secretPath = "api/github";
  envVar = [ "GITHUB_TOKEN" "GH_TOKEN" "GITHUB_API_KEY" ];
  createPathVar = false;
})
```

## What gets created automatically

For each secret, the helper creates:

1. **SOPS secret definition** with proper path and permissions
2. **Environment variable** with secret content (via shell init)
3. **Optional PATH variable** pointing to the secret file
4. **Shell initialization code** for both zsh and bash

## Files created by default

Secrets without custom `filePath` are stored in:

```bash
~/.local/share/secrets/[secretPath with / replaced by -]
```

Example:

- `"keys/atuin"` → `~/.local/share/secrets/keys-atuin`
- `"api/github"` → `~/.local/share/secrets/api-github`
