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
        # TODO: Look into exa
        ls = "ls -F --color=always";
        ll = "ls -la";
        l = "ls";

        ".." = "cd ..";
        dev = "cd ~/Developer/";
      };
      plugins = [{
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }];
    };
    starship = { enable = true; };
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
