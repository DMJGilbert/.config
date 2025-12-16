# Library Functions

Helper functions for creating system configurations.

## Files

| File | Purpose |
|------|---------|
| `mkdarwin.nix` | Creates nix-darwin configurations for macOS |
| `mknixos.nix` | Creates NixOS configurations for Linux |

## mkdarwin.nix

Creates a complete nix-darwin system configuration.

**Usage in `flake.nix`:**

```nix
darwinConfigurations.hostname = mkDarwin "hostname" {
  inherit darwin nixpkgs home-manager overlays sops-nix;
  system = "aarch64-darwin";  # or x86_64-darwin
  user = "username";
};
```

**What it loads:**

- `machines/[hostname].nix` - System configuration
- `users/[user]/darwin.nix` - User system settings
- `users/[user]/sops.nix` - Secrets configuration
- `users/[user]/home-manager.nix` - Home Manager config
- Applies overlays from `overlays/`

## mknixos.nix

Creates a complete NixOS system configuration.

**Usage in `flake.nix`:**

```nix
nixosConfigurations.hostname = mkNixos "hostname" {
  inherit hardware nixpkgs home-manager overlays;
  system = "x86_64-linux";  # or aarch64-linux
  user = "username";
  extraModules = [
    # Additional modules
  ];
};
```

**What it loads:**

- `hardware/[hostname].nix` - Hardware configuration
- `machines/[hostname].nix` - System configuration
- `users/[user]/nixos.nix` - User system settings
- `users/[user]/home-manager.nix` - Home Manager config
- Applies overlays and extraModules

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
  inherit hardware nixpkgs home-manager overlays;
  system = "x86_64-linux";
  user = "darren";
  extraModules = [];
};
```
