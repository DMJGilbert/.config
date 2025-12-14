# User Configuration

Home Manager configuration for the `darren` user.

## Structure

```
users/darren/
├── home-manager.nix   # Home Manager entry point (cross-platform)
├── darwin.nix         # macOS-specific user settings
├── nixos.nix          # NixOS-specific user settings
├── sops.nix           # Secrets management
├── zsh.nix            # Shell configuration
├── git.nix            # Git configuration
├── nvim.nix           # Neovim configuration
├── aerospace.nix      # Window manager (macOS)
├── claude-code.nix    # Claude Code commands
└── config/            # Dotfiles and application configs
```

## Key Files

| File | Purpose |
|------|---------|
| `home-manager.nix` | Imports all modules, sets packages |
| `darwin.nix` | macOS user settings (not Home Manager) |
| `nixos.nix` | NixOS user settings (not Home Manager) |
| `zsh.nix` | Shell aliases, plugins, environment |
| `git.nix` | Git config, aliases, delta |
| `nvim.nix` | Neovim plugins, LSP, keybindings |
| `claude-code.nix` | Links Claude Code commands |

## Adding Packages

Edit `home-manager.nix`:

```nix
home.packages = with pkgs; [
  # existing packages
  new-package
];
```

Search: `nix search nixpkgs [name]`

## Adding Shell Aliases

Edit `zsh.nix`:

```nix
programs.zsh.shellAliases = {
  alias-name = "command";
};
```

## Adding Environment Variables

Edit `zsh.nix`:

```nix
home.sessionVariables = {
  VARIABLE = "value";
};
```

## Adding Dotfiles

Place files in `config/` and link in `home-manager.nix`:

```nix
home.file.".config/app" = {
  source = ./config/app;
  recursive = true;
};
```

Or use XDG:

```nix
xdg.configFile."app/config.toml".source = ./config/app/config.toml;
```

## Platform-Specific Config

- **macOS only**: Add to `darwin.nix` (system-level) or use `lib.mkIf pkgs.stdenv.isDarwin` in `home-manager.nix`
- **NixOS only**: Add to `nixos.nix` (system-level) or use `lib.mkIf pkgs.stdenv.isLinux` in `home-manager.nix`
