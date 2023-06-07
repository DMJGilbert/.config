{pkgs, ...}: {
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
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
    # wezterm
    # discord
    teams
    zoom-us
    slack
    obsidian
    openconnect
    keepassxc
    # qmk

    # development
    pkgconf
    cmake
    openssl
    direnv
    nix-direnv

    # libs
    fdk_aac

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
  programs.zsh = import ./zsh.nix pkgs;
  programs.git = import ./git.nix pkgs;
  programs.bat.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.exa = {
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
    target = ".config/yabai/yabairc";
    source = ./config/yabai/yabairc;
    recursive = true;
  };

  home.file.i3 = {
    target = ".config/i3";
    source = ./config/i3;
    recursive = true;
  };
}
