{pkgs, ...}: {
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    borders

    # neovim
    tree-sitter
    nil
    alejandra
    shellcheck
    shfmt
    statix
    luajitPackages.lua-lsp
    sumneko-lua-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint_d
    nodePackages."@tailwindcss/language-server"

    # tools
    # wezterm
    # discord
    teams
    zoom-us
    slack
    obsidian
    openconnect
    # keepassxc

    # development
    pkgconf
    cmake
    direnv
    nix-direnv
    stylua

    # nodejs
    nodejs_20
    # rust
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy
  ];
  manual.manpages.enable = false;
  programs.zsh = import ./zsh.nix pkgs;
  programs.git = import ./git.nix pkgs;
  programs.bat.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.eza = {
    enable = true;
    enableAliases = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
  home.file.nvim = {
    target = ".config/nvim";
    source = ./config/nvim;
    recursive = true;
  };

  programs.starship = {enable = true;};
  home.file.starship = {
    target = ".config/starship.toml";
    source = ./config/starship/starship.toml;
  };

  home.file.wezterm = {
    target = ".config/wezterm";
    source = ./config/wezterm;
    recursive = true;
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };
  home.file.zellij = {
    target = ".config/zellij";
    source = ./config/zellij;
    recursive = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Services
  home.file.skhd = {
    executable = true;
    target = ".config/skhd/skhdrc";
    source = ./config/skhd/skhdrc;
    recursive = true;
  };
  home.file.yabai = {
    executable = true;
    target = ".config/yabai";
    source = ./config/yabai;
    recursive = true;
  };

  home.file.awesome = {
    target = ".config/awesome";
    source = ./config/awesome;
    recursive = true;
  };
  home.file.i3 = {
    target = ".config/i3";
    source = ./config/i3;
    recursive = true;
  };
  home.file.i3status = {
    target = ".config/i3status";
    source = ./config/i3status;
    recursive = true;
  };
}
