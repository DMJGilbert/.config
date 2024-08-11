{
  description = "DMJGilbert Home Manager & NixOS configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    darwin,
    hardware,
    nixpkgs,
    home-manager,
    ...
  }: let
    mkDarwin = import ./lib/mkdarwin.nix;
    mkNixos = import ./lib/mknixos.nix;
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      (import ./overlays/pkgs.nix)
    ];
  in {
    darwinConfigurations.ryukyu = mkDarwin "ryukyu" {
      inherit darwin nixpkgs home-manager overlays;
      system = "aarch64-darwin";
      user = "darren";
    };
    nixosConfigurations.rubecula = mkNixos "rubecula" {
      inherit hardware nixpkgs home-manager overlays;
      system = "x86_64-linux";
      user = "darren";
      extraModules = [
        hardware.nixosModules.apple-t2
      ];
    };
  };
}
