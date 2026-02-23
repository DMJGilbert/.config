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

      # Enable Claude Code LSP integration
      export ENABLE_LSP_TOOL=1

      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search # Up
      bindkey "^[[B" down-line-or-beginning-search # Down

      # Claude Code with MCP secrets (reads from sops-nix decrypted files)
      # Secrets only loaded for the duration of the claude command
      claude-mcp() {
        local missing_secrets=()
        [[ ! -r /run/secrets/GITHUB_PERSONAL_ACCESS_TOKEN ]] && missing_secrets+=("GITHUB_PERSONAL_ACCESS_TOKEN")
        [[ ! -r /run/secrets/HASS_HOST ]] && missing_secrets+=("HASS_HOST")
        [[ ! -r /run/secrets/HASS_TOKEN ]] && missing_secrets+=("HASS_TOKEN")
        [[ ! -r /run/secrets/OBSIDIAN_API_KEY ]] && missing_secrets+=("OBSIDIAN_API_KEY")
        [[ ! -r /run/secrets/OBSIDIAN_HOST ]] && missing_secrets+=("OBSIDIAN_HOST")
        [[ ! -r /run/secrets/OBSIDIAN_PORT ]] && missing_secrets+=("OBSIDIAN_PORT")

        if (( ''${#missing_secrets[@]} > 0 )); then
          echo "⚠️  Missing secrets: ''${missing_secrets[*]}" >&2
          echo "   Some MCP servers may not work. Rebuild your config to decrypt secrets." >&2
        fi

        GITHUB_PERSONAL_ACCESS_TOKEN="$(cat /run/secrets/GITHUB_PERSONAL_ACCESS_TOKEN 2>/dev/null)" \
        HASS_HOST="$(cat /run/secrets/HASS_HOST 2>/dev/null)" \
        HASS_TOKEN="$(cat /run/secrets/HASS_TOKEN 2>/dev/null)" \
        OBSIDIAN_API_KEY="$(cat /run/secrets/OBSIDIAN_API_KEY 2>/dev/null)" \
        OBSIDIAN_HOST="$(cat /run/secrets/OBSIDIAN_HOST 2>/dev/null)" \
        OBSIDIAN_PORT="$(cat /run/secrets/OBSIDIAN_PORT 2>/dev/null)" \
        claude "$@"
      }

      # Claude Code with local Ollama backend + MCP secrets
      # Requires: ollama serve running on localhost:11434
      # Usage: ccode-local --model qwen3:32b
      claude-local() {
        if ! curl -s --max-time 1 http://localhost:11434/api/tags >/dev/null 2>&1; then
          echo "⚠️  Ollama not running. Start with: ollama serve" >&2
          return 1
        fi

        # Remind user to specify model if not provided
        if [[ ! " $* " =~ " --model " ]] && [[ ! " $* " =~ " -m " ]]; then
          echo "💡 Tip: Specify a model with --model <name> (e.g., --model qwen3:32b)" >&2
          echo "   Available models: ollama list" >&2
        fi

        local missing_secrets=()
        [[ ! -r /run/secrets/GITHUB_PERSONAL_ACCESS_TOKEN ]] && missing_secrets+=("GITHUB_PERSONAL_ACCESS_TOKEN")
        [[ ! -r /run/secrets/HASS_HOST ]] && missing_secrets+=("HASS_HOST")
        [[ ! -r /run/secrets/HASS_TOKEN ]] && missing_secrets+=("HASS_TOKEN")
        [[ ! -r /run/secrets/OBSIDIAN_API_KEY ]] && missing_secrets+=("OBSIDIAN_API_KEY")
        [[ ! -r /run/secrets/OBSIDIAN_HOST ]] && missing_secrets+=("OBSIDIAN_HOST")
        [[ ! -r /run/secrets/OBSIDIAN_PORT ]] && missing_secrets+=("OBSIDIAN_PORT")

        if (( ''${#missing_secrets[@]} > 0 )); then
          echo "⚠️  Missing secrets: ''${missing_secrets[*]}" >&2
          echo "   Some MCP servers may not work. Rebuild your config to decrypt secrets." >&2
        fi

        ANTHROPIC_BASE_URL="http://localhost:11434" \
        ANTHROPIC_API_KEY="ollama" \
        ANTHROPIC_AUTH_TOKEN="ollama" \
        GITHUB_PERSONAL_ACCESS_TOKEN="$(cat /run/secrets/GITHUB_PERSONAL_ACCESS_TOKEN 2>/dev/null)" \
        HASS_HOST="$(cat /run/secrets/HASS_HOST 2>/dev/null)" \
        HASS_TOKEN="$(cat /run/secrets/HASS_TOKEN 2>/dev/null)" \
        OBSIDIAN_API_KEY="$(cat /run/secrets/OBSIDIAN_API_KEY 2>/dev/null)" \
        OBSIDIAN_HOST="$(cat /run/secrets/OBSIDIAN_HOST 2>/dev/null)" \
        OBSIDIAN_PORT="$(cat /run/secrets/OBSIDIAN_PORT 2>/dev/null)" \
        claude "$@"
      }
    '';
    shellAliases = {
      # Claude Code (using 'ccode' to avoid conflict with C compiler 'cc')
      ccode = "claude-mcp";
      ccode-local = "claude-local";

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
