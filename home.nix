{ pkgs, lib, ... }:
let
  imports = [
  ];
in
{
  inherit imports;

  home = {
    stateVersion = "22.05";
    username = "darren";
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
