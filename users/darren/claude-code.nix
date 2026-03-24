{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  home = {
    activation = {
      # Ensure memory storage directory exists for MCP knowledge graph
      createClaudeMemoryDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $HOME/.local/share/claude
      '';

      # Symlink agent memory directories into Obsidian vault
      # This allows memory: user auto-injection while keeping files in the vault
      linkAgentMemoryToVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
        VAULT="$HOME/Developer/dmjgilbert/vault/claude/memory"
        AGENT_MEM="$HOME/.claude/agent-memory"
        $DRY_RUN_CMD mkdir -p "$VAULT/researcher"
        $DRY_RUN_CMD mkdir -p "$VAULT/planner"
        $DRY_RUN_CMD mkdir -p "$AGENT_MEM"
        $DRY_RUN_CMD ln -sfn "$VAULT/researcher" "$AGENT_MEM/researcher"
        $DRY_RUN_CMD ln -sfn "$VAULT/planner" "$AGENT_MEM/planner"
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

      # Slash commands (linked as directory)
      ".claude/commands" = {
        source = ./config/claude/commands;
        recursive = true;
      };

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
    };
  };
}
