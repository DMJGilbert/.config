{ pkgs, lib, ... }:
let imports = [ ];
in {
  inherit imports;

  home = {
    stateVersion = "22.05";
    username = "darren";
  };
  programs = {
    zsh = {
      enable = true;
      history = rec {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        size = 1000000;
        save = size;
        path = "$HOME/.local/share/zsh/history";
      };
      enableAutosuggestions = true;
      enableCompletion = true;
      initExtra = ''
        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search # Up
        bindkey "^[[B" down-line-or-beginning-search # Down
      '';
      shellAliases = {
        ls = "exa --color=auto";
        ll = "exa -la";
        la = "exa -a";
        l = "exa";
        ".." = "cd ..";
      };
      plugins = [
        {
          name = "fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          };
        }
      ];
    };
    starship = { enable = true; };
    zellij = {
      enable = true;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    git = {
      enable = true;
      userName = "DMJGilbert";
      userEmail = "dmjgilbert@me.com";
      extraConfig = {
        init.defaultBranch = "main";
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519";
        commit.gpgsign = true;
        github = { user = "DMJGilbert"; };
      };
      lfs.enable = true;
    };
  };
  home.file.starship = {
    target = ".config/starship.toml";
    source = ./modules/starship.toml;
  };
  home.file.nvim = {
    target = ".config/nvim";
    source = ./modules/nvim;
    recursive = true;
  };
  home.file.skhd = {
    executable = true;
    target = ".config/skhd/skhdrc";
    source = ./modules/skhd/skhdrc;
    recursive = true;
  };
  home.file.wezterm = {
    target = ".config/wezterm";
    source = ./modules/wezterm;
    recursive = true;
  };
  home.file.yabai = {
    executable = true;
    target = ".config/yabai/yabairc";
    source = ./modules/yabai/yabairc;
    recursive = true;
  };
  home.file.zellij = {
    target = ".config/zellij";
    source = ./modules/zellij;
    recursive = true;
  };
}
