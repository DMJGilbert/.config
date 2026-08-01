final: prev: {
  # Fix direnv build: CGO_ENABLED=0 conflicts with -linkmode=external in Makefile
  direnv = prev.direnv.overrideAttrs (old: {
    env = (old.env or {}) // {CGO_ENABLED = 1;};
  });

  # Matter server crashes on startup when the DCL serves a PAA root certificate
  # that pyca/cryptography's ASN.1 parser rejects (ValueError -> unhandled ->
  # server never binds :5580, all Matter devices go unavailable). Patch it to
  # log and skip the bad cert. Remove once fixed upstream (still broken on main
  # as of 8.1.2). See overlays/python-matter-server-skip-bad-paa.patch.
  python-matter-server = prev.python-matter-server.overridePythonAttrs (old: {
    patches = (old.patches or []) ++ [./python-matter-server-skip-bad-paa.patch];
  });

  cross-seed = final.callPackage ./cross-seed.nix {};
  hass-catppuccin = final.callPackage ./hass-catppuccin.nix {};
  lovelace-tabbed-card = final.callPackage ./lovelace-tabbed-card.nix {};
  lovelace-layout-card = final.callPackage ./lovelace-layout-card.nix {};
  lovelace-stack-in-card = final.callPackage ./lovelace-stack-in-card.nix {};
  lovelace-state-switch = final.callPackage ./lovelace-state-switch.nix {};
  modern-circular-gauge = final.callPackage ./modern-circular-gauge.nix {};
  ha-floorplan = final.callPackage ./ha-floorplan.nix {};
}
