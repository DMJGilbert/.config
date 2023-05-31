{ pkgs, ... }: {
  nix.useDaemon = true;
  nix.configureBuildUsers = true;
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "darren" "@admin" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages =
    [ "nodejs-16.20.0" "python-2.7.18.6" ];

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bashInteractive zsh ];
  environment.systemPackages = with pkgs; [ lazygit ripgrep fzf fd bat exa ];

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs;
    [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];
}
