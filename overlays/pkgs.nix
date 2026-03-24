final: prev: {
  # Fix direnv build: CGO_ENABLED=0 conflicts with -linkmode=external in Makefile
  direnv = prev.direnv.overrideAttrs (old: {
    env = (old.env or {}) // {CGO_ENABLED = 1;};
  });
  hass-catppuccin = final.callPackage ./hass-catppuccin.nix {};
  lovelace-tabbed-card = final.callPackage ./lovelace-tabbed-card.nix {};
  lovelace-layout-card = final.callPackage ./lovelace-layout-card.nix {};
  lovelace-stack-in-card = final.callPackage ./lovelace-stack-in-card.nix {};
  lovelace-state-switch = final.callPackage ./lovelace-state-switch.nix {};
  modern-circular-gauge = final.callPackage ./modern-circular-gauge.nix {};
  ha-floorplan = final.callPackage ./ha-floorplan.nix {};
}
