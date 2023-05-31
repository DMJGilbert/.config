{
  description = "DMJGilbert Home Manager & NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { darwin, nixpkgs, home-manager, ... }:
    let
      mkDarwin = import ./lib/mkdarwin.nix;
      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [ ];
    in {
      darwinConfigurations.rubecula = mkDarwin "rubecula" {
        inherit darwin nixpkgs home-manager overlays;
        system = "x86_64-darwin";
        user = "darren";
      };
    };
}
