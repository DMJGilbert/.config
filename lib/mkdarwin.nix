# This function creates a nix-darwin system.
name: {
  darwin,
  home-manager,
  system,
  user,
  overlays,
  sops-nix,
  ...
}:
darwin.lib.darwinSystem rec {
  inherit system;

  # Pass currentSystem via specialArgs so it's available at module definition time
  # (without causing infinite recursion like _module.args would)
  specialArgs = {
    currentSystemName = name;
    currentSystem = system;
  };

  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    {nixpkgs.overlays = overlays;}

    # Encrypted secrets management
    sops-nix.darwinModules.sops

    ../modules
    (../machines + "/${name}.nix")
    (../users + "/${user}/darwin.nix")
    (../users + "/${user}/sops.nix")
    home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${user} = import ../users/${user}/home-manager.nix;
      };
    }
  ];
}
