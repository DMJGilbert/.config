{pkgs, ...}: {
  nix = {
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel" "@admin"];
      substituters = ["https://nix-config.cachix.org" "https://nix-community.cachix.org"];
      trusted-public-keys = [
        "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  programs.zsh.enable = true;
  environment.shells = with pkgs; [bashInteractive zsh];
  environment.systemPackages = with pkgs; [
    lazygit
    ripgrep
    fzf
    fd
    bat
    eza
  ];
  environment.variables.EDITOR = "nvim";
  environment.variables.TERMINAL = "wezterm";
  environment.variables.BROWSER = "librewolf";

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [(nerdfonts.override {fonts = ["SourceCodePro"];})];
}
