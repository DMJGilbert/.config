# User Configuration

Home Manager configuration for the `darren` user.

## Structure

```
users/darren/
├── home-manager.nix      # Home Manager entry point (cross-platform)
├── darwin-user.nix       # macOS users.users.darren (system user, no HM)
├── darwin-homebrew.nix   # Homebrew brews + casks (split from old darwin.nix)
├── nixos.nix             # NixOS users.users.darren incl. authorizedKeys + hashedPasswordFile
├── sops.nix              # User-level sops secrets (claude.yaml)
├── zsh.nix               # Shell configuration
├── git.nix               # Git configuration
├── nvim/                 # Neovim configuration (directory)
├── aerospace.nix         # Window manager (macOS) — references pkgs.aerospace via store path
├── claude-code.nix       # Claude Code config symlinks + agent-memory wiring (darwin only)
└── config/               # Dotfiles and application configs (nvim, zsh, claude, etc.)
```

## Key Files

| File                  | Purpose                                                                              |
| --------------------- | ------------------------------------------------------------------------------------ |
| `home-manager.nix`    | Imports all modules, sets packages                                                   |
| `darwin-user.nix`     | macOS user account (passed via `extraUserModules`)                                   |
| `darwin-homebrew.nix` | Homebrew brews/casks (split for composability)                                       |
| `nixos.nix`           | NixOS user (passed via `extraUserModules`) + SSH authorizedKeys                      |
| `sops.nix`            | User-level sops: keyFile from `config.users.users.darren.home`                       |
| `zsh.nix`             | Shell aliases, plugins, environment                                                  |
| `git.nix`             | Git config, aliases, delta                                                           |
| `nvim/`               | Neovim plugins, LSP, keybindings                                                     |
| `claude-code.nix`     | Symlinks `~/.claude/*` from `config/claude/`; links agent memory into Obsidian vault |

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

- **macOS only**: Add to `darwin-user.nix` (system user) or `darwin-homebrew.nix` (casks), or use `lib.mkIf pkgs.stdenv.isDarwin` in `home-manager.nix`
- **NixOS only**: Add to `nixos.nix` (system user) or use `lib.mkIf pkgs.stdenv.isLinux` in `home-manager.nix`
