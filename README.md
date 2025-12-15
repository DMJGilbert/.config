# Nix Configuration

[![CI](https://github.com/DMJGilbert/.config/actions/workflows/ci.yml/badge.svg)](https://github.com/DMJGilbert/.config/actions/workflows/ci.yml)

Personal Nix configurations for macOS and NixOS systems, managed with Nix Flakes, nix-darwin, and Home Manager.

This repository is open source for educational purposes. Feel free to reference, adapt, or learn from these configurations for your own systems.

## Architecture

```
flake.nix
    │
    ├── lib/mkdarwin.nix ──► darwinConfigurations.ryukyu
    │       │
    │       ├── machines/ryukyu.nix      (system config)
    │       ├── users/darren/darwin.nix  (user system config)
    │       └── users/darren/home-manager.nix (home config)
    │
    └── lib/mknixos.nix ──► nixosConfigurations.rubecula
            │
            ├── hardware/rubecula.nix    (hardware config)
            ├── machines/rubecula.nix    (system config)
            ├── users/darren/nixos.nix   (user system config)
            └── users/darren/home-manager.nix (home config)
```

## Systems

| Host | Platform | Description |
|------|----------|-------------|
| `ryukyu` | macOS (Apple Silicon) | Primary development machine |
| `rubecula` | NixOS (Intel) | Home server running on MacBook Pro with T2 chip |

## Quick Reference

| Task | Command |
|------|---------|
| Rebuild macOS | `darwin-rebuild switch --flake .#ryukyu` |
| Rebuild NixOS | `sudo nixos-rebuild switch --flake .#rubecula` |
| Update inputs | `nix flake update` |
| Check flake | `nix flake check` |
| Format code | `alejandra .` |
| Search packages | `nix search nixpkgs [name]` |

## Structure

```
.
├── flake.nix                 # Flake definition and system outputs
├── flake.lock                # Locked dependencies
├── lib/                      # System builder functions
│   ├── mkdarwin.nix          # Darwin system builder
│   └── mknixos.nix           # NixOS system builder
├── machines/                 # Machine-specific configurations
│   ├── shared.nix            # Shared configuration across systems
│   ├── ryukyu.nix            # macOS-specific configuration
│   └── rubecula.nix          # NixOS-specific configuration
├── users/darren/             # User configuration (Home Manager)
│   ├── home-manager.nix      # Home Manager entry point
│   ├── darwin.nix            # macOS user configuration
│   ├── nixos.nix             # NixOS user configuration
│   └── config/               # Dotfiles and configs
├── modules/                  # Reusable NixOS modules
│   └── home-assistant/       # Home Assistant configuration
├── overlays/                 # Package overlays
│   └── pkgs.nix              # Custom packages
└── hardware/                 # Hardware configurations
    └── rubecula.nix          # Hardware configuration
```

See module-specific documentation:
- [lib/README.md](./lib/README.md) - System builder functions
- [modules/home-assistant/README.md](./modules/home-assistant/README.md) - Home Assistant module
- [overlays/README.md](./overlays/README.md) - Custom packages
- [users/darren/README.md](./users/darren/README.md) - User configuration

## Features

### macOS (ryukyu)

- **nix-darwin** for system configuration
- **Homebrew** integration for casks and GUI applications
- **AeroSpace** tiling window manager with SketchyBar
- Touch ID for sudo authentication
- Sensible macOS defaults (Finder, Dock, keyboard)

### NixOS (rubecula)

- **Home Assistant** with declarative configuration
- **Intel hardware optimisation** (microcode, graphics, thermal management)
- **Power management** with auto-cpufreq and thermald
- **Zigbee** support via Sonoff USB dongle
- **Matter** protocol server
- **AdGuard Home** for DNS-level ad blocking
- **Tailscale** for mesh networking
- **Nginx** reverse proxy with ACME certificates

### Shared (Home Manager)

- **Zsh** with syntax highlighting, autosuggestions, and starship prompt
- **Neovim** with LSP, Treesitter, and Telescope
- **Git** with delta diffs and SSH signing
- **Modern CLI tools**: eza, bat, ripgrep, fzf, zoxide, btop
- **Development**: Node.js, Rust, direnv with nix-direnv
- **Claude Code** slash commands for code review, commit messages, and more

## Claude Code Commands

Custom slash commands for Claude Code, available via shell functions that support arguments:

| Function | Command | Description |
|----------|---------|-------------|
| `cc-prime` | `/prime` | Prime Claude with project context |
| `cc-review` | `/review` | Code review of staged changes |
| `cc-commit` | `/commit` | Generate conventional commit message |
| `cc-pr` | `/pr` | Generate PR description |
| `cc-perf` | `/perf` | Performance audit |
| `cc-health` | `/health` | Project health assessment |
| `cc-security` | `/security` | Security audit |
| `cc-explain` | `/explain` | Explain code sections |
| `cc-deps` | `/deps` | Dependency audit |

All commands support arguments via `$ARGUMENTS`:

```bash
cc-prime                      # Full project context
cc-prime src/                 # Focus on specific directory
cc-explain src/auth.ts:45-80  # Explain specific lines
cc-security src/api/          # Audit specific directory
cc-health dependencies        # Focus on specific area
cc-deps npm vulnerabilities   # Filter by ecosystem/check
cc-commit feat                # Hint commit type
cc-pr develop                 # Target specific base branch
```

All commands are read-only and will not modify files, commit, or push.

## Key Dependencies

- [nixpkgs](https://github.com/NixOS/nixpkgs) (unstable)
- [home-manager](https://github.com/nix-community/home-manager)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [nixos-hardware](https://github.com/NixOS/nixos-hardware)

## License

This configuration is provided as-is for educational purposes. Use at your own discretion.
