# Library Functions

Helper functions for creating system configurations.

## Files

| File                   | Purpose                                                                             |
| ---------------------- | ----------------------------------------------------------------------------------- |
| `mkdarwin.nix`         | Creates nix-darwin configurations for macOS                                         |
| `mknixos.nix`          | Creates NixOS configurations for Linux                                              |
| `mkhome.nix`           | Creates standalone Home Manager configurations (any host)                           |
| `mkMediaService.nix`   | Helper for sonarr/radarr/prowlarr-style services — used by `modules/services/*.nix` |
| `treefmt-includes.nix` | Shared prettier include list — consumed by `flake.nix` and home-manager             |

## mkdarwin.nix

Creates a complete nix-darwin system configuration. User-specific modules are passed in by the caller (`extraUserModules`) so the helper isn't tied to any one user's filesystem layout.

**Usage in `flake.nix`:**

```nix
darwinConfigurations.hostname = mkDarwin "hostname" {
  inherit darwin nixpkgs home-manager overlays sops-nix;
  system = "aarch64-darwin";  # or x86_64-darwin
  user = "username";
  homeManagerUser = ./users/username/home-manager.nix;
  extraUserModules = [
    ./users/username/darwin-user.nix       # users.users.<name>
    ./users/username/darwin-homebrew.nix   # brews/casks
    ./users/username/sops.nix
  ];
};
```

**What it loads:**

- `machines/[hostname].nix` — system configuration
- All `extraUserModules` (per-user system config + sops)
- Home Manager config from `homeManagerUser` (linked under `users.${user}`)
- Applies overlays from `overlays/`
- Provides `isLinux` / `isDarwin` via `specialArgs` so modules don't re-derive from `currentSystem`

## mknixos.nix

Creates a complete NixOS system configuration. As with `mkdarwin.nix`, user-specific modules are passed in by the caller.

**Usage in `flake.nix`:**

```nix
nixosConfigurations.hostname = mkNixos "hostname" {
  inherit hardware nixpkgs home-manager overlays sops-nix;
  system = "x86_64-linux";  # or aarch64-linux
  user = "username";
  homeManagerUser = ./users/username/home-manager.nix;
  extraUserModules = [
    ./users/username/nixos.nix
    ./users/username/sops.nix
  ];
  extraModules = [
    hardware.nixosModules.common-cpu-amd
    # …
  ];
};
```

**What it loads:**

- `hardware/[hostname].nix` — hardware configuration
- `machines/[hostname].nix` — system configuration
- All `extraUserModules` (per-user system config + sops)
- Home Manager config from `homeManagerUser`
- Applies overlays and `extraModules`
- Provides `isLinux` / `isDarwin` via `specialArgs`

## mkhome.nix

Creates a standalone Home Manager configuration that can be deployed independently
of the OS, enabling fast iteration on user-space changes without a full system rebuild.

The same `users/[user]/home-manager.nix` is used by both this builder and the OS
module integration in `mkdarwin`/`mknixos`, so both deployment paths stay in sync.

**Usage in `flake.nix`:**

```nix
homeConfigurations."user@hostname" = mkHome {
  inherit nixpkgs home-manager overlays;
  system = "aarch64-darwin";  # or x86_64-linux
  user = "username";
  homeDirectory = "/Users/username";  # or /home/username
};
```

**Deploy:**

```bash
nh home switch . -c ryukyu              # macOS
nh home switch . -c rubecula            # NixOS
home-manager switch --flake .#ryukyu    # explicit fallback
```

**What it loads:**

- `users/[user]/home-manager.nix` — shared home config (same file as OS module path)
- Sets `home.username` and `home.homeDirectory` from arguments
- Creates its own nixpkgs instance with overlays and a scoped `allowUnfreePredicate` (Zoom, Slack, Obsidian, Teams, etc. — see `mkhome.nix` for the canonical list)

---

## Adding a New Machine

### macOS

1. Create `machines/[hostname].nix`:

```nix
{pkgs, ...}: {
  imports = [./shared.nix];

  # System packages
  environment.systemPackages = with pkgs; [];

  # macOS defaults
  system.defaults = {
    dock.autohide = true;
  };

  system.stateVersion = 4;
}
```

2. Add to `flake.nix`:

```nix
darwinConfigurations.[hostname] = mkDarwin "[hostname]" {
  inherit darwin nixpkgs home-manager overlays sops-nix;
  system = "aarch64-darwin";
  user = "darren";
  homeManagerUser = ./users/darren/home-manager.nix;
  extraUserModules = [
    ./users/darren/darwin-user.nix
    ./users/darren/darwin-homebrew.nix
    ./users/darren/sops.nix
  ];
};
```

### NixOS

1. Generate hardware config:

```bash
nixos-generate-config --show-hardware-config > hardware/[hostname].nix
```

2. Create `machines/[hostname].nix`:

```nix
{pkgs, ...}: {
  imports = [./shared.nix];

  networking.hostName = "[hostname]";

  environment.systemPackages = with pkgs; [];

  system.stateVersion = "24.05";
}
```

3. Add to `flake.nix`:

```nix
nixosConfigurations.[hostname] = mkNixos "[hostname]" {
  inherit hardware nixpkgs home-manager overlays sops-nix;
  system = "x86_64-linux";
  user = "darren";
  homeManagerUser = ./users/darren/home-manager.nix;
  extraUserModules = [
    ./users/darren/nixos.nix
    ./users/darren/sops.nix
  ];
  extraModules = [];
};
```
