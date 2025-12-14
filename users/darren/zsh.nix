{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    history = rec {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      size = 1000000;
      save = size;
      path = "$HOME/.local/share/zsh/history";
    };
    autosuggestion = {enable = true;};
    enableCompletion = true;
    completionInit = "autoload -Uz compinit && compinit -u";
    initContent = lib.mkBefore ''
      # Homebrew PATH for macOS (Apple Silicon and Intel)
      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi

      # SOPS age key location
      export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search # Up
      bindkey "^[[B" down-line-or-beginning-search # Down

      # Claude Code with MCP secrets (reads from sops-nix decrypted files)
      # Secrets only loaded for the duration of the claude command
      claude-mcp() {
        GITHUB_PERSONAL_ACCESS_TOKEN="$(cat /run/secrets/GITHUB_PERSONAL_ACCESS_TOKEN 2>/dev/null)" \
        FIGMA_ACCESS_TOKEN="$(cat /run/secrets/FIGMA_ACCESS_TOKEN 2>/dev/null)" \
        HASS_HOST="$(cat /run/secrets/HASS_HOST 2>/dev/null)" \
        HASS_TOKEN="$(cat /run/secrets/HASS_TOKEN 2>/dev/null)" \
        claude "$@"
      }

      # Claude Code workflows (functions for argument support)
      # Use claude-mcp for MCP server access, claude for basic usage
      cc-review() { claude-mcp "/review $*"; }
      cc-commit() { claude-mcp "/commit $*"; }
      cc-pr() { claude-mcp "/pr $*"; }
      cc-perf() { claude-mcp "/perf $*"; }
      cc-health() { claude-mcp "/health $*"; }
      cc-security() { claude-mcp "/security $*"; }
      cc-explain() { claude-mcp "/explain $*"; }
      cc-deps() { claude-mcp "/deps $*"; }
      cc-prime() { claude-mcp "/prime $*"; }
      cc-audit() { claude-mcp "/audit $*"; }
      cc-orchestrate() { claude-mcp "/orchestrate $*"; }
    '';
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Eza (better ls)
      ls = "eza";
      ll = "eza -la --git";
      la = "eza -a";
      lt = "eza --tree --level=2";
      lta = "eza --tree --level=2 -a";

      # Modern replacements
      cat = "bat";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btop";

      # Git shortcuts
      g = "git";
      ga = "git add";
      gc = "git commit";
      gca = "git commit --amend";
      gco = "git checkout";
      gd = "git diff";
      gp = "git push";
      gpl = "git pull";
      gst = "git status";
      gl = "git lg";

      # Editors
      vim = "nvim";
      v = "nvim";

      # Misc
      c = "clear";
      reload = "source ~/.zshrc";
      path = "echo $PATH | tr ':' '\\n'";
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
}
