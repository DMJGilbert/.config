final: prev: {
  # Fix direnv build: CGO_ENABLED=0 conflicts with -linkmode=external in Makefile
  direnv = prev.direnv.overrideAttrs (old: {
    env = (old.env or {}) // {CGO_ENABLED = 1;};
  });

  # v6.13.7 handles qBittorrent HTTP 204 bypass-auth responses correctly (v6.13.6 treats them as failures)
  cross-seed = final.callPackage (
    {
      lib,
      buildNpmPackage,
      fetchFromGitHub,
    }:
      buildNpmPackage rec {
        pname = "cross-seed";
        version = "6.13.7";
        src = fetchFromGitHub {
          owner = "cross-seed";
          repo = "cross-seed";
          tag = "v${version}";
          hash = "sha256-+7A4UGIY75hvF0JvtIr6nGNdXkUE0XV9TFpEQz9OW+Y=";
        };
        npmDepsHash = "sha256-HoIiO7cj4JNY+sJEuH1v0AgagDuBTySJaoVo/4SsfIc=";
        meta = {
          description = "Fully-automatic torrent cross-seeding with Torznab";
          homepage = "https://cross-seed.org";
          license = lib.licenses.asl20;
          mainProgram = "cross-seed";
          maintainers = with lib.maintainers; [mkez];
        };
      }
  ) {};
  hass-catppuccin = final.callPackage ./hass-catppuccin.nix {};
  lovelace-tabbed-card = final.callPackage ./lovelace-tabbed-card.nix {};
  lovelace-layout-card = final.callPackage ./lovelace-layout-card.nix {};
  lovelace-stack-in-card = final.callPackage ./lovelace-stack-in-card.nix {};
  lovelace-state-switch = final.callPackage ./lovelace-state-switch.nix {};
  modern-circular-gauge = final.callPackage ./modern-circular-gauge.nix {};
  ha-floorplan = final.callPackage ./ha-floorplan.nix {};
}
