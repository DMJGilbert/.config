{
  description = "DMJGilbert Home Manager & NixOS configurations";
  nixConfig = {
    extra-substituters = ["https://cache.soopy.moe"];
    extra-trusted-public-keys = ["cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="];
  };
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    darwin,
    hardware,
    nixpkgs,
    home-manager,
    sops-nix,
    ...
  } @ inputs: let
    mkDarwin = import ./lib/mkdarwin.nix;
    mkNixos = import ./lib/mknixos.nix;
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      (import ./overlays/pkgs.nix)
    ];
    # Systems to generate devShells and checks for
    forAllSystems = nixpkgs.lib.genAttrs ["aarch64-darwin" "x86_64-linux"];
  in {
    # Development shell for working on this config
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra # Nix formatter
          statix # Nix linter
          deadnix # Find dead code
          nil # Nix LSP
        ];
        shellHook = ''
          echo "🔧 Nix config development shell"
          echo "  alejandra .  - format nix files"
          echo "  statix check - lint nix files"
          echo "  deadnix .    - find dead code"
        '';
      };
    });

    # Flake checks for CI
    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatting = pkgs.runCommand "check-formatting" {} ''
        ${pkgs.alejandra}/bin/alejandra --check ${inputs.self} 2>/dev/null || {
          echo "Run 'alejandra .' to fix formatting"
          exit 1
        }
        touch $out
      '';
      linting = pkgs.runCommand "check-linting" {} ''
        ${pkgs.statix}/bin/statix check ${inputs.self} || {
          echo "Fix linting issues above"
          exit 1
        }
        touch $out
      '';
    });

    darwinConfigurations.ryukyu = mkDarwin "ryukyu" {
      inherit darwin nixpkgs home-manager overlays sops-nix;
      system = "aarch64-darwin";
      user = "darren";
    };
    nixosConfigurations.rubecula = mkNixos "rubecula" {
      inherit hardware nixpkgs home-manager overlays;
      system = "x86_64-linux";
      user = "darren";
      extraModules = [
        hardware.nixosModules.apple-t2
        hardware.nixosModules.common-cpu-intel
        hardware.nixosModules.common-pc-laptop-ssd
        hardware.nixosModules.common-gpu-amd
      ];
    };
  };
}
