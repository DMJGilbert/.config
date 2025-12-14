# Overlays

Package overlays for custom builds not available in nixpkgs.

## Structure

```
overlays/
├── pkgs.nix                    # Main overlay (imports all packages)
├── hass-bubble-card.nix        # Home Assistant Bubble Card
├── hass-catppuccin.nix         # Catppuccin theme for HA
├── lovelace-auto-entities.nix  # Auto-entities card
├── lovelace-layout-card.nix    # Layout card
├── lovelace-tabbed-card.nix    # Tabbed card
└── README.md
```

## Packages

| Package | Description |
|---------|-------------|
| `hass-bubble-card` | Floating action buttons for Home Assistant |
| `hass-catppuccin` | Catppuccin theme for Home Assistant |
| `lovelace-auto-entities` | Automatically populate entities in cards |
| `lovelace-layout-card` | Custom grid layouts for dashboards |
| `lovelace-tabbed-card` | Tabbed container card |

## Adding a New Package

1. **Create package file** `overlays/[package-name].nix`:

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "author";
    repo = "repo";
    rev = "v${version}";
    hash = "";  # Build once to get hash
  };

  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
  '';

  meta = {
    description = "Package description";
    homepage = "https://github.com/author/repo";
    license = lib.licenses.mit;
  };
}
```

2. **Add to `pkgs.nix`**:

```nix
final: prev: {
  # existing packages...
  package-name = final.callPackage ./package-name.nix {};
}
```

3. **Get the hash** by building:

```bash
nix build .#package-name
# Copy hash from error message
```

## Testing

```bash
# Build specific package
nix build .#hass-bubble-card

# Check package exists in config
nix eval .#nixosConfigurations.rubecula.pkgs.hass-bubble-card
```
