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
      ]
      ++ pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
        teams-for-linux
      ])
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
        teams
        borders
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
      wezterm = {
        target = ".config/wezterm";
        source = ./config/wezterm;
        recursive = true;
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
      awesome = {
        target = ".config/awesome";
        source = ./config/awesome;
        recursive = true;
      };
      i3 = {
        target = ".config/i3";
        source = ./config/i3;
        recursive = true;
      };
      i3status = {
        target = ".config/i3status";
        source = ./config/i3status;
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
    eza = {
      enable = true;
      enableAliases = true;
    };
    starship = {enable = true;};
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
