{
  description = "DMJGilbert Home Manager & NixOS configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:wegank/nix-darwin/mddoc-remove";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    darwin,
    nixpkgs,
    home-manager,
    ...
  }: let
    mkDarwin = import ./lib/mkdarwin.nix;
    mkNixos = import ./lib/mknixos.nix;
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      (import ./overlays/yabai.nix)
      (import ./overlays/pkgs.nix)
    ];
  in {
    darwinConfigurations.rubecula = mkDarwin "rubecula" {
      inherit darwin nixpkgs home-manager overlays;
      system = "x86_64-darwin";
      user = "darren";
    };
    nixosConfigurations.erithacus = mkNixos "erithacus" {
      inherit nixpkgs home-manager overlays;
      system = "x86_64-linux";
      user = "darren";
    };
    nixosConfigurations.passerine = mkNixos "passerine" {
      inherit nixpkgs home-manager overlays;
      system = "x86_64-linux";
      user = "darren";
    };
  };
}
