{ pkgs, ... }: {
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    skhd
    lazygit
    ripgrep
    fzf
    fd
    wezterm
    qmk
    bat
    exa

    # neovim
    tree-sitter
    nil
    nixfmt
    shellcheck
    shfmt
    luajitPackages.lua-lsp
    sumneko-lua-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint_d
    nodePackages."@tailwindcss/language-server"

    # tools
    discord
    teams
    zoom-us
    slack
    obsidian
    openconnect
    keepassxc

    # development
    pkgconf
    cmake
    openssl
    # nodejs
    nodejs-16_x
    python2
    # rust
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy
  ];
  programs.zsh = import ./zsh.nix (pkgs);
  programs.git = import ./git.nix (pkgs);

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

  programs.starship = { enable = true; };
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
    target = ".config/yabai/yabairc";
    source = ./config/yabai/yabairc;
    recursive = true;
  };
}
