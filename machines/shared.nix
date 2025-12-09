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
      # Enable ccache in sandbox builds
      substituters = [
        "https://cache.nixos.org"
        "https://cache.soopy.moe"
        "https://nix-community.cachix.org"
        "https://nixpkgs-python.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
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
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };

  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [bashInteractive zsh];
    systemPackages = with pkgs; [
      lazygit
      ripgrep
      fzf
      fd
      bat
      eza

      # python312Packages.getmac
      # python312Packages.aiohomekit
      # python312Packages.aiowebostv
    ];
    variables = {
      EDITOR = "nvim";
      TERMINAL = "wezterm";
      BROWSER = "librewolf";
    };
  };

  fonts = {
    packages = with pkgs; [nerd-fonts.sauce-code-pro];
  };
}
