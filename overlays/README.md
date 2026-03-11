# Overlays

Package overlays for custom builds not available in nixpkgs.

## Structure

```
overlays/
├── pkgs.nix                    # Main overlay (imports all packages)
├── ha-floorplan.nix            # Floorplan for HA
├── hass-catppuccin.nix         # Catppuccin theme for HA
├── lovelace-layout-card.nix    # Layout card
├── lovelace-stack-in-card.nix  # Stack-in-card
├── lovelace-state-switch.nix   # State switch card
├── lovelace-tabbed-card.nix    # Tabbed card
├── modern-circular-gauge.nix   # Circular gauge card
└── README.md
```

## Packages

| Package                  | Description                                        |
| ------------------------ | -------------------------------------------------- |
| `ha-floorplan`           | SVG floor plans for Home Assistant                 |
| `hass-catppuccin`        | Catppuccin theme for Home Assistant                |
| `lovelace-layout-card`   | Custom grid layouts for dashboards                 |
| `lovelace-stack-in-card` | Group cards into one with no borders               |
| `lovelace-state-switch`  | Dynamically replace cards depending on state       |
| `lovelace-tabbed-card`   | Tabbed container card                              |
| `modern-circular-gauge`  | Modern circular gauge card                         |

Packages available in nixpkgs (use `home-assistant-custom-lovelace-modules.*`):
`bubble-card`, `auto-entities`

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
nix build .#lovelace-tabbed-card

# Check package exists in config
nix eval .#nixosConfigurations.rubecula.pkgs.lovelace-tabbed-card
```
