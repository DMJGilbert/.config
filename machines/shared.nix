{pkgs, ...}: {
  nix = {
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel" "@admin"];
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
