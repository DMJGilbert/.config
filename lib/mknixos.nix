# This function creates a NixOS system.
# The caller passes user-specific modules (per-user nixos.nix, sops.nix) and the
# home-manager user config via `extraUserModules` / `homeManagerUser`, so the
# helper does not hardcode any specific username's filesystem layout.
name: {
  nixpkgs,
  home-manager,
  system,
  user,
  overlays,
  sops-nix,
  homeManagerUser,
  extraModules ? [],
  extraUserModules ? [],
  ...
}:
nixpkgs.lib.nixosSystem {
  inherit system;

  # Pass currentSystem via specialArgs so it's available at module definition time
  # (without causing infinite recursion like _module.args would)
  specialArgs = {
    currentSystemName = name;
    currentSystem = system;
    isLinux = builtins.match ".*-linux" system != null;
    isDarwin = builtins.match ".*-darwin" system != null;
  };

  modules =
    [
      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}

      # Encrypted secrets management
      sops-nix.nixosModules.sops

      ../modules
      (../hardware + "/${name}.nix")
      (../machines + "/${name}.nix")
      home-manager.nixosModules.home-manager
      ({pkgs, ...}: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          # Timestamped backups rather than a fixed ".bak" — see lib/hm-backup.nix.
          backupCommand = "${import ./hm-backup.nix pkgs}/bin/hm-backup-file";
          users.${user} = homeManagerUser;
        };
      })
    ]
    ++ extraUserModules
    ++ extraModules;
}
