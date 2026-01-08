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

      # Claude Code workflows (functions for argument support)
      # Use claude-mcp for MCP server access, claude for basic usage
      # Code quality and review
      cc-review() { claude-mcp "/review $*"; }
      cc-audit() { claude-mcp "/audit $*"; }
      cc-perf() { claude-mcp "/perf $*"; }
      cc-security() { claude-mcp "/security $*"; }
      cc-health() { claude-mcp "/health $*"; }
      cc-deps() { claude-mcp "/deps $*"; }

      # Git workflows
      cc-commit() { claude-mcp "/commit $*"; }
      cc-pr() { claude-mcp "/pr $*"; }

      # Context and memory
      cc-prime() { claude-mcp "/prime $*"; }
      cc-remember() { claude-mcp "/remember $*"; }

      # Problem solving (CEK techniques)
      cc-fix() { claude-mcp "/fix $*"; }
      cc-why() { claude-mcp "/why $*"; }
      cc-reflect() { claude-mcp "/reflect $*"; }
      cc-brainstorm() { claude-mcp "/brainstorm $*"; }

      # Documentation and explanation
      cc-explain() { claude-mcp "/explain $*"; }

      # Obsidian vault
      cc-note() { claude-mcp "/note $*"; }
      cc-spec() { claude-mcp "/spec $*"; }
      cc-doc() { claude-mcp "/doc $*"; }
      cc-search-vault() { claude-mcp "/search-vault $*"; }

      # Orchestration
      cc-orchestrate() { claude-mcp "/orchestrate $*"; }

      # Autonomous iteration (Ralph)
      cc-ralph-loop() { claude-mcp "/ralph-loop $*"; }
      cc-ralph-status() { claude-mcp "/ralph-status $*"; }
      cc-cancel-ralph() { claude-mcp "/cancel-ralph $*"; }

      # Session retrospectives
      cc-retrospective() { claude-mcp "/retrospective $*"; }

      # Domain presets (pre-configured sessions for common workflows)
      # Usage: ccode-nix "fix the flake" or just ccode-nix for interactive
      # Uses --append-system-prompt to preserve Claude Code defaults while adding focus
      ccode-nix() {
        claude-mcp --append-system-prompt "Focus: Nix, flakes, home-manager, nix-darwin. Use nix-specialist agent for implementation. Run alejandra after edits." "$@"
      }
      ccode-frontend() {
        claude-mcp --append-system-prompt "Focus: React, TypeScript, Tailwind, shadcn/ui. Use frontend-developer agent for implementation. Use ui-ux-designer for styling." "$@"
      }
      ccode-backend() {
        claude-mcp --append-system-prompt "Focus: APIs, Node.js, Express, databases. Use backend-developer agent for implementation. Use database-specialist for SQL/schema work." "$@"
      }
      ccode-audit() {
        claude-mcp --append-system-prompt "Focus: Code quality and security. Run /security, /audit, /review commands. Use code-reviewer and security-auditor agents." "$@"
      }
      ccode-ha() {
        claude-mcp --append-system-prompt "Focus: Home Assistant automations, dashboards, integrations. Use home-assistant-dev agent. Query entities before making changes." "$@"
      }
    '';
    shellAliases = {
      # Claude Code (using 'ccode' to avoid conflict with C compiler 'cc')
      ccode = "claude-mcp";

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
