# Nix Configuration

Personal Nix configurations for macOS and NixOS systems, managed with Nix Flakes, nix-darwin, and Home Manager.

This repository is open source for educational purposes. Feel free to reference, adapt, or learn from these configurations for your own systems.

## Systems

| Host | Platform | Description |
|------|----------|-------------|
| `ryukyu` | macOS (Apple Silicon) | Primary development machine |
| `rubecula` | NixOS (Intel) | Home server running on MacBook Pro with T2 chip |

## Structure

```
.
├── flake.nix                 # Flake definition and system outputs
├── flake.lock                # Locked dependencies
├── lib/
│   ├── mkdarwin.nix          # Darwin system builder
│   └── mknixos.nix           # NixOS system builder
├── machines/
│   ├── shared.nix            # Shared configuration across systems
│   ├── ryukyu.nix            # macOS-specific configuration
│   └── rubecula.nix          # NixOS-specific configuration
├── users/
│   └── darren/
│       ├── home-manager.nix  # Home Manager entry point
│       ├── darwin.nix        # macOS user configuration
│       ├── nixos.nix         # NixOS user configuration
│       ├── zsh.nix           # Shell configuration
│       ├── git.nix           # Git configuration
│       ├── nvim.nix          # Neovim configuration
│       ├── aerospace.nix     # Window manager (macOS)
│       ├── claude-code.nix   # Claude Code commands
│       └── config/           # Dotfiles and configs
├── modules/
│   └── home-assistant/       # Home Assistant configuration
│       ├── components.nix
│       ├── automations.nix
│       └── dashboard.nix
├── overlays/
│   └── pkgs.nix              # Package overlays
└── hardware/
    └── rubecula.nix          # Hardware configuration
```

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

## Usage

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- For macOS: [nix-darwin](https://github.com/LnL7/nix-darwin)

### Building

**macOS:**
```bash
darwin-rebuild switch --flake .#ryukyu
```

**NixOS:**
```bash
sudo nixos-rebuild switch --flake .#rubecula
```

### Updating

```bash
nix flake update
```

### Checking

```bash
nix flake check
```

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
- [arion](https://github.com/hercules-ci/arion) (Docker Compose in Nix)

## Formatting

This project uses [alejandra](https://github.com/kamadorueda/alejandra) for Nix formatting:

```bash
alejandra .
```

## License

This configuration is provided as-is for educational purposes. Use at your own discretion.
