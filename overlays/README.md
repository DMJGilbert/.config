# Overlays

Package overlays for custom builds not available in nixpkgs.

## Structure

```
overlays/
├── pkgs.nix                    # Overlay entry — wires the per-package files below
├── cross-seed.nix              # Pinned cross-seed (qBittorrent 204-bypass fix)
├── ha-floorplan.nix            # Floorplan for HA
├── hass-catppuccin.nix         # Catppuccin theme for HA
├── lovelace-layout-card.nix    # Layout card
├── lovelace-state-switch.nix   # State switch card
└── README.md
```

`pkgs.nix` only contains tiny overrides (e.g., `direnv` CGO fix) and `final.callPackage ./<file>.nix {}` references — never inline derivations.

## Packages

| Package                 | Description                                                                   |
| ----------------------- | ----------------------------------------------------------------------------- |
| `cross-seed`            | Cross-seeding bot, pinned to v6.13.7 (fixes qBittorrent HTTP 204 bypass-auth) |
| `ha-floorplan`          | SVG floor plans for Home Assistant                                            |
| `hass-catppuccin`       | Catppuccin theme for Home Assistant                                           |
| `lovelace-layout-card`  | Custom grid layouts for dashboards                                            |
| `lovelace-state-switch` | Dynamically replace cards depending on state                                  |

Packages available in nixpkgs (use `home-assistant-custom-lovelace-modules.*`):
`bubble-card`, `auto-entities`, `mushroom`, `button-card`, `card-mod`

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
nix build .#lovelace-layout-card

# Check package exists in config
nix eval .#nixosConfigurations.rubecula.pkgs.lovelace-layout-card
```
