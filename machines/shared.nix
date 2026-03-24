{pkgs, ...}: {
  nix = {
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel" "@admin"];
      # Parallel build optimization
      cores = 0; # Use all available cores
      max-jobs = "auto"; # Auto-detect number of parallel jobs
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-python.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
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
  nixpkgs.config.allowUnfree = true;

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
