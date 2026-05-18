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
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = {
    darwin,
    hardware,
    nixpkgs,
    home-manager,
    sops-nix,
    treefmt-nix,
    pre-commit-hooks,
    impermanence,
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

    # treefmt configuration shared across all systems
    treefmtEval = forAllSystems (system:
      treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
        projectRootFile = "flake.nix";
        programs = {
          alejandra.enable = true;
          stylua.enable = true;
          prettier = {
            enable = true;
            includes = [
              "*.json"
              "*.yaml"
              "*.yml"
              "*.md"
              "*.ts"
              "*.tsx"
              "*.js"
              "*.css"
              "*.html"
            ];
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
    in {
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
    });

    darwinConfigurations.ryukyu = mkDarwin "ryukyu" {
      inherit darwin nixpkgs home-manager overlays sops-nix;
      system = "aarch64-darwin";
      user = "darren";
    };
    nixosConfigurations.rubecula = mkNixos "rubecula" {
      inherit hardware nixpkgs home-manager overlays sops-nix;
      system = "x86_64-linux";
      user = "darren";
      extraModules = [
        hardware.nixosModules.common-cpu-amd
        hardware.nixosModules.common-gpu-amd
        impermanence.nixosModules.impermanence
      ];
    };
  };
}
