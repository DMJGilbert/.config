{ pkgs, ... }: {
  nix.useDaemon = true;
  nix.configureBuildUsers = true;
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "root" "@admin" ];
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages =
    [ "nodejs-16.20.0" "python-2.7.18.6" ];

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bashInteractive zsh ];
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs;
    [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];
}
