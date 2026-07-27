{
  pkgs,
  lib,
  ...
}: {
  nix = {
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "darren"];
      # Parallel build optimization
      cores = 0; # Use all available cores
      max-jobs = "auto"; # Auto-detect number of parallel jobs
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-python.cachix.org"
        "https://iofq.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
        "iofq.cachix.org-1:54GHlWCnp/MZ+kXBcXMhfF1aoMJsyAMBvUlqEMXLuOE="
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
    };
    extraOptions = ''
      !include /etc/nix/access-tokens
    '';
  };
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "zoom"
      "zoom-us"
      "slack"
      "obsidian"
      "neotest-vitest"
    ];

  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [bashInteractive zsh];
    systemPackages = with pkgs; [
      lazygit
    ];
    variables = {
      EDITOR = "nvim";
      TERMINAL = "wezterm";
    };
  };
}
