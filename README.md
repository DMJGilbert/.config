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
    │       ├── machines/ryukyu.nix       (system config)
    │       ├── users/darren/darwin.nix   (user system config)
    │       └── users/darren/home-manager.nix (home config)
    │
    └── lib/mknixos.nix ──► nixosConfigurations.rubecula
            │
            ├── hardware/rubecula.nix     (hardware config)
            ├── disko/rubecula.nix        (declarative disk layout — for reinstalls)
            ├── machines/rubecula.nix     (system config)
            ├── users/darren/nixos.nix    (user system config)
            └── users/darren/home-manager.nix (home config)
```

## Systems

| Host       | Platform              | Description                                     |
| ---------- | --------------------- | ----------------------------------------------- |
| `ryukyu`   | macOS (Apple Silicon) | Primary development machine                     |
| `rubecula` | NixOS (x86_64)        | Homelab server — AMD Ryzen 8845HS + Radeon 780M |

## Quick Reference

| Task            | Command                               |
| --------------- | ------------------------------------- |
| Rebuild macOS   | `nh darwin switch .#ryukyu`           |
| Rebuild NixOS   | `nh os switch .#rubecula`             |
| Update inputs   | `nix flake update`                    |
| Check flake     | `nix flake check`                     |
| Format code     | `nix fmt`                             |
| Generation diff | `nvd diff /run/current-system result` |
| Search packages | `nix search nixpkgs [name]`           |

## Structure

```
.
├── flake.nix                 # Flake definition, inputs, and system outputs
├── flake.lock                # Locked dependencies
├── lib/                      # System builder functions
│   ├── mkdarwin.nix          # Darwin system builder
│   └── mknixos.nix           # NixOS system builder
├── machines/                 # Machine-specific configurations
│   ├── shared.nix            # Shared Nix daemon / substituter config
│   ├── ryukyu.nix            # macOS system config
│   └── rubecula.nix          # NixOS homelab config
├── hardware/                 # Hardware configurations
│   └── rubecula.nix          # AMD CPU, disk UUIDs, boot
├── disko/                    # Declarative disk layouts (for nixos-anywhere installs)
│   └── rubecula.nix          # btrfs + impermanence-ready layout
├── modules/                  # Reusable NixOS modules (local.* option namespace)
│   ├── hardware/             # AMD/Intel GPU, laptop power management
│   ├── features/             # ccache, docker, ollama
│   ├── profiles/             # server meta-profile
│   └── services/             # All homelab services
├── overlays/                 # Package overlays (HA Lovelace modules, etc.)
│   └── pkgs.nix
├── users/darren/             # User configuration (Home Manager + system user)
│   ├── home-manager.nix      # Shared HM entry point
│   ├── darwin.nix            # macOS user config (Homebrew, launchd)
│   ├── nixos.nix             # NixOS user config
│   ├── sops.nix              # User-level sops secrets (claude.yaml)
│   └── config/               # Dotfiles: nvim, zsh, sketchybar, wezterm, claude
└── secrets/                  # Age-encrypted sops secrets
    ├── claude.yaml           # Cross-host secrets (HASS, GitHub, Obsidian)
    └── rubecula.yaml         # Host-specific secrets (Mullvad WG, API keys)
```

## Features

### macOS (ryukyu)

- **nix-darwin** for system configuration
- **Homebrew** integration for casks and GUI applications (Docker, Flutter, Obsidian, WezTerm, etc.)
- **AeroSpace** tiling window manager with SketchyBar status bar
- **Ollama** local LLM inference (`qwen2.5-coder:7b-base`)
- Touch ID for sudo authentication

### NixOS homelab (rubecula)

**Media stack:**

| Service     | Purpose                           | Port |
| ----------- | --------------------------------- | ---- |
| Jellyfin    | Media server                      | 8096 |
| Sonarr      | TV automation                     | 8989 |
| Radarr      | Movie automation                  | 7878 |
| Prowlarr    | Indexer manager                   | 9696 |
| Jellyseerr  | Request management                | 5055 |
| qBittorrent | Torrent client (VPN kill-switch)  | 8081 |
| Tdarr       | Automated transcoding (AMD VAAPI) | 8265 |
| Pinchflat   | YouTube archiver                  | 8945 |
| iPlayarr    | BBC iPlayer bridge                | 4404 |
| Recyclarr   | TRaSH Guides sync (Sonarr/Radarr) | —    |
| cross-seed  | Cross-seeding automation          | 2468 |

**Home automation:**

| Service          | Purpose                                      |
| ---------------- | -------------------------------------------- |
| Home Assistant   | Central automation hub with 30+ integrations |
| Zigbee2MQTT      | Zigbee device bridge (Sonoff dongle)         |
| MQTT (Mosquitto) | Local message broker                         |
| Matter Server    | Thread/Matter protocol                       |

**Infrastructure:**

| Service      | Purpose                                             |
| ------------ | --------------------------------------------------- |
| AdGuard Home | DNS ad-blocking                                     |
| Nginx        | Reverse proxy with wildcard ACME (Namecheap DNS-01) |
| Tailscale    | Mesh VPN                                            |
| Homepage     | Homelab dashboard with live widget data             |
| Uptime Kuma  | Uptime monitoring                                   |
| Glances      | System metrics API (HA integration)                 |
| FlareSolverr | Cloudflare bypass (routed via VPN)                  |

**Networking:**

- WireGuard network namespace kill-switch for qBittorrent (Mullvad)
- SOCKS5 proxy inside VPN namespace for FlareSolverr
- Veth pair bridges host nginx to in-namespace services
- Wildcard `*.gilberts.one` TLS via Namecheap DNS-01 ACME challenge

### Shared (Home Manager)

- **Zsh** with fast-syntax-highlighting, starship prompt (catppuccin frappe)
- **Neovim** 0.11 with native LSP, blink.cmp, telescope, neotest, catppuccin
- **Zellij** terminal multiplexer (catppuccin frappe)
- **Yazi** TUI file manager
- **Git** with delta diffs and SSH signing
- **Modern CLI**: eza, bat, ripgrep, fzf, zoxide, btop, yazi, nh, nvd
- **Development**: Node.js 24, Rust toolchain, Python (uv), direnv + nix-direnv
- **Secrets**: sops + age
- **Claude Code** with full skill set and MCP servers

## Claude Code Skills

| Skill            | Purpose                                                 |
| ---------------- | ------------------------------------------------------- |
| `/commit`        | Generate conventional commit message for staged changes |
| `/fix [problem]` | Problem-solving with RIPER workflow                     |
| `/review`        | Code review of current branch                           |
| `/simplify`      | Review changed code for quality and efficiency          |
| `/retrospective` | Session review and agent memory update                  |

## Key Dependencies

- [nixpkgs](https://github.com/NixOS/nixpkgs) (unstable)
- [home-manager](https://github.com/nix-community/home-manager)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [nixos-hardware](https://github.com/NixOS/nixos-hardware)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [treefmt-nix](https://github.com/numtide/treefmt-nix)
- [impermanence](https://github.com/nix-community/impermanence)
- [disko](https://github.com/nix-community/disko)

## License

This configuration is provided as-is for educational purposes. Use at your own discretion.
