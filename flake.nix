{
  description = "DMJGilbert Home Manager & NixOS configurations";
  nixConfig = {
    extra-substituters = [
      "https://iofq.cachix.org"
    ];
    extra-trusted-public-keys = [
      "iofq.cachix.org-1:54GHlWCnp/MZ+kXBcXMhfF1aoMJsyAMBvUlqEMXLuOE="
    ];
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs = {
    darwin,
    hardware,
    nixpkgs,
    home-manager,
    sops-nix,
    treefmt-nix,
    pre-commit-hooks,
    disko,
    impermanence,
    ...
  } @ inputs: let
    mkDarwin = import ./lib/mkdarwin.nix;
    mkNixos = import ./lib/mknixos.nix;
    mkHome = import ./lib/mkhome.nix;
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      (import ./overlays/pkgs.nix)
    ];
    # Systems to generate devShells and checks for
    forAllSystems = nixpkgs.lib.genAttrs ["aarch64-darwin" "x86_64-linux"];
    # Standalone Home Manager configs — defined here so checks can reference them.
    homeConfigurations = {
      ryukyu = mkHome {
        inherit nixpkgs home-manager overlays;
        system = "aarch64-darwin";
        user = "darren";
        homeDirectory = "/Users/darren";
      };
      rubecula = mkHome {
        inherit nixpkgs home-manager overlays;
        system = "x86_64-linux";
        user = "darren";
        homeDirectory = "/home/darren";
      };
    };

    # treefmt configuration shared across all systems
    treefmtIncludes = import ./lib/treefmt-includes.nix;
    treefmtEval = forAllSystems (system:
      treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
        projectRootFile = "flake.nix";
        programs = {
          alejandra.enable = true;
          stylua.enable = true;
          prettier = {
            enable = true;
            includes = treefmtIncludes.prettier;
          };
          rustfmt.enable = true;
        };
      });

    # pre-commit hooks configuration shared across all systems
    preCommitChecks = forAllSystems (system:
      pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          treefmt = {
            enable = true;
            package = treefmtEval.${system}.config.build.wrapper;
          };
          statix.enable = true;
          deadnix.enable = true;
          # shellcheck fires per-staged-file, so legacy scripts only get
          # caught when next edited (progressive improvement).
          shellcheck.enable = true;
          yamllint = {
            enable = true;
            # secrets/ contains sops-encrypted YAML with long ciphertext lines
            excludes = ["^secrets/"];
          };
        };
      });
  in {
    # Expose treefmt wrapper as the flake formatter (used by `nix fmt`)
    formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

    # Development shell for working on this config
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages =
          (with pkgs; [
            nil # Nix LSP
            markdownlint-cli2 # Markdown linter
            yamllint # YAML linter
          ])
          ++ [treefmtEval.${system}.config.build.wrapper]
          ++ preCommitChecks.${system}.enabledPackages;
        shellHook = ''
          ${preCommitChecks.${system}.shellHook}
        '';
      };
    });

    # Flake checks for CI
    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      {
        formatting = treefmtEval.${system}.config.build.check inputs.self;
        pre-commit = preCommitChecks.${system};
        markdown = pkgs.runCommand "check-markdown" {} ''
          ${pkgs.findutils}/bin/find ${inputs.self} -name '*.md' -type f \
            -not -path '*/.git/*' -print0 | \
            ${pkgs.findutils}/bin/xargs -0 \
            ${pkgs.markdownlint-cli2}/bin/markdownlint-cli2 \
            --config ${./.markdownlint-cli2.yaml} \
            2>&1 || {
            echo ""
            echo "Fix markdown issues with: markdownlint-cli2 --fix '**/*.md'"
            exit 1
          }
          touch $out
        '';
        # Cross-system evaluation smoke checks. These reference
        # `.activationPackage.drvPath` (a string), forcing the home-manager
        # module tree to fully evaluate without building any platform-specific
        # binaries. Catches eval errors (missing options, type mismatches,
        # broken assertions) before the change reaches the matching runner.
        home-darren-ryukyu-eval = pkgs.runCommand "home-darren-ryukyu-eval" {
          drvPath = builtins.unsafeDiscardStringContext homeConfigurations.ryukyu.activationPackage.drvPath;
        } "echo ryukyu drv: $drvPath > $out";

        home-darren-rubecula-eval = pkgs.runCommand "home-darren-rubecula-eval" {
          drvPath = builtins.unsafeDiscardStringContext homeConfigurations.rubecula.activationPackage.drvPath;
        } "echo rubecula drv: $drvPath > $out";
      }
      # Full activation-package build only on the matching runner — the
      # derivation contains platform-native binaries that can't cross-build.
      // pkgs.lib.optionalAttrs (system == "aarch64-darwin") {
        home-darren-ryukyu = homeConfigurations.ryukyu.activationPackage;
      }
      // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
        home-darren-rubecula = homeConfigurations.rubecula.activationPackage;
      });

    darwinConfigurations.ryukyu = mkDarwin "ryukyu" {
      inherit darwin nixpkgs home-manager overlays sops-nix;
      system = "aarch64-darwin";
      user = "darren";
      homeManagerUser = ./users/darren/home-manager.nix;
      extraUserModules = [
        ./users/darren/darwin-user.nix
        ./users/darren/darwin-homebrew.nix
        ./users/darren/sops.nix
      ];
    };
    nixosConfigurations.rubecula = mkNixos "rubecula" {
      inherit hardware nixpkgs home-manager overlays sops-nix;
      system = "x86_64-linux";
      user = "darren";
      homeManagerUser = ./users/darren/home-manager.nix;
      extraUserModules = [
        ./users/darren/nixos.nix
        ./users/darren/sops.nix
      ];
      extraModules = [
        hardware.nixosModules.common-cpu-amd
        hardware.nixosModules.common-gpu-amd
        impermanence.nixosModules.impermanence
      ];
    };

    # Fresh-install variant for nixos-anywhere — applies the disko btrfs layout
    # at install time, overriding the ext4 mkDefault mounts in hardware/rubecula.nix.
    # Run: nix run github:nix-community/nixos-anywhere -- --flake .#rubecula-install root@<ip>
    # After a successful reinstall, fold disko into .#rubecula and remove this output.
    nixosConfigurations.rubecula-install = mkNixos "rubecula" {
      inherit hardware nixpkgs home-manager overlays sops-nix;
      system = "x86_64-linux";
      user = "darren";
      homeManagerUser = ./users/darren/home-manager.nix;
      extraUserModules = [
        ./users/darren/nixos.nix
        ./users/darren/sops.nix
      ];
      extraModules = [
        hardware.nixosModules.common-cpu-amd
        hardware.nixosModules.common-gpu-amd
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
        ./disko/rubecula.nix
      ];
    };

    inherit homeConfigurations;
  };
}
