# This function creates a NixOS system.
name: {
  hardware,
  nixpkgs,
  home-manager,
  system,
  user,
  overlays,
  extraModules ? [],
}:
nixpkgs.lib.nixosSystem rec {
  inherit system;

  modules =
    [
      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}

      (../hardware + "/${name}.nix")
      (../machines + "/${name}.nix")
      (../users + "/${user}/nixos.nix")
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user} = import ../users/${user}/home-manager.nix;
        };
      }

      # We expose some extra arguments so that our modules can parameterize
      # better based on these values.
      {
        config._module.args = {
          currentSystemName = name;
          currentSystem = system;
        };
      }
    ]
    ++ extraModules;
}
