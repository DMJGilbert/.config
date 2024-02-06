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
      options = "--delete-older-than 30d";
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
    ];
    variables = {
      EDITOR = "nvim";
      TERMINAL = "wezterm";
      BROWSER = "librewolf";
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [(nerdfonts.override {fonts = ["SourceCodePro"];})];
  };
}
