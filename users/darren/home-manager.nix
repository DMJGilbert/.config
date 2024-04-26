{pkgs, ...}: {
  home = {
    stateVersion = "23.11";
    packages = with pkgs;
      [
        # neovim
        tree-sitter
        nil
        alejandra
        shellcheck
        shfmt
        statix
        biome
        prettierd
        luajitPackages.lua-lsp
        sumneko-lua-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages.typescript-language-server
        nodePackages.prettier
        nodePackages.eslint_d
        nodePackages."@tailwindcss/language-server"

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
      ]
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
        # tools
        zoom-us
        slack
        obsidian
        openconnect
        # keepassxc

        teams
        jankyborders
        cocoapods
      ]);
    file = {
      nvim = {
        target = ".config/nvim";
        source = ./config/nvim;
        recursive = true;
      };
      starship = {
        target = ".config/starship.toml";
        source = ./config/starship/starship.toml;
      };
      zellij = {
        target = ".config/zellij";
        source = ./config/zellij;
        recursive = true;
      };
      skhd = {
        executable = true;
        target = ".config/skhd/skhdrc";
        source = ./config/skhd/skhdrc;
        recursive = true;
      };
      yabai = {
        executable = true;
        target = ".config/yabai";
        source = ./config/yabai;
        recursive = true;
      };
    };
  };

  manual.manpages.enable = false;
  programs = {
    zsh = import ./zsh.nix pkgs;
    git = import ./git.nix pkgs;
    bat.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    eza.enable = true;
    wezterm = {
      enable = true;
      # install wezterm via homebrew on macOS to avoid compilation, dummy package here.
      package =
        if pkgs.stdenv.isLinux
        then pkgs.wezterm
        else pkgs.hello;
      enableBashIntegration = pkgs.stdenv.isLinux;
      enableZshIntegration = pkgs.stdenv.isLinux;
      extraConfig = ''
        ${builtins.readFile ./config/wezterm/wezterm.lua}
      '';
    };
    starship.enable = true;
    zellij = {
      enable = true;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
