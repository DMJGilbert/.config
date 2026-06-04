{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  home = {
    activation = {
      # Symlink agent memory directories into Obsidian vault.
      # This allows `memory: user` auto-injection while keeping files in the vault.
      # `ln -sfn` only replaces an existing *symlink* — if a real directory
      # already exists at the destination, it would create the link INSIDE that
      # directory. Guard against that by checking and warning rather than
      # destroying any pre-existing local memory.
      linkAgentMemoryToVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
        VAULT="$HOME/Developer/dmjgilbert/vault/claude/memory"
        AGENT_MEM="$HOME/.claude/agent-memory"
        $DRY_RUN_CMD mkdir -p "$AGENT_MEM"
        for agent in researcher planner nix hass rust dart frontend backend ui security-reviewer bug-hunter quality-reviewer; do
          $DRY_RUN_CMD mkdir -p "$VAULT/$agent"
          if [ -L "$AGENT_MEM/$agent" ] || [ ! -e "$AGENT_MEM/$agent" ]; then
            $DRY_RUN_CMD ln -sfn "$VAULT/$agent" "$AGENT_MEM/$agent"
          else
            echo "WARN: $AGENT_MEM/$agent exists as a non-symlink; move its contents to $VAULT/$agent then rm it and re-run home-manager activation." >&2
          fi
        done
      '';
    };

    file = {
      # Global memory storage directory
      ".local/share/claude-memory/.keep".text = "";

      # Project guidelines
      ".claude/CLAUDE.md".source = ./config/claude/CLAUDE.md;

      # Settings (LSP plugins, model preferences)
      ".claude/settings.json".source = ./config/claude/settings.json;

      # MCP configuration
      ".mcp.json".source = ./config/claude/mcp.json;

      # Hooks configuration
      ".claude/hooks.json".source = ./config/claude/hooks.json;

      # Specialist agents (linked as directory)
      ".claude/agents" = {
        source = ./config/claude/agents;
        recursive = true;
      };

      # Skills (auto-invoked based on context)
      ".claude/skills" = {
        source = ./config/claude/skills;
        recursive = true;
      };

      # Path-scoped rules (loaded contextually by file type)
      ".claude/rules" = {
        source = ./config/claude/rules;
        recursive = true;
      };

      # Scripts (hooks and automation)
      ".claude/scripts" = {
        source = ./config/claude/scripts;
        recursive = true;
      };

      # Saved workflows (dynamic workflow descriptors)
      ".claude/workflows" = {
        source = ./config/claude/workflows;
        recursive = true;
      };
    };
  };
}
