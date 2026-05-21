# This function creates a standalone home-manager configuration.
{
  nixpkgs,
  home-manager,
  system,
  user,
  homeDirectory,
  overlays,
  ...
}:
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };
  modules = [
    {
      home.username = user;
      home.homeDirectory = homeDirectory;
    }
    (../users + "/${user}/home-manager.nix")
  ];
}
