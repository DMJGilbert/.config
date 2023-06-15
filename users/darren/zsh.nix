{pkgs, ...}: {
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
  shellAliases = {".." = "cd ..";};
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
}
