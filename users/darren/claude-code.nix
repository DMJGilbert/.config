{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  # Ensure memory storage directory exists for MCP knowledge graph
  home.activation.createClaudeMemoryDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.local/share/claude
  '';

  home.file = {
    # Project guidelines
    ".claude/CLAUDE.md".source = ./config/claude/CLAUDE.md;

    # MCP configuration
    ".mcp.json".source = ./config/claude/mcp.json;

    # Hooks configuration
    ".claude/hooks.json".source = ./config/claude/hooks.json;

    # Slash commands
    ".claude/commands/review.md".source = ./config/claude/commands/review.md;
    ".claude/commands/commit.md".source = ./config/claude/commands/commit.md;
    ".claude/commands/pr.md".source = ./config/claude/commands/pr.md;
    ".claude/commands/perf.md".source = ./config/claude/commands/perf.md;
    ".claude/commands/health.md".source = ./config/claude/commands/health.md;
    ".claude/commands/security.md".source = ./config/claude/commands/security.md;
    ".claude/commands/explain.md".source = ./config/claude/commands/explain.md;
    ".claude/commands/deps.md".source = ./config/claude/commands/deps.md;
    ".claude/commands/prime.md".source = ./config/claude/commands/prime.md;
    ".claude/commands/audit.md".source = ./config/claude/commands/audit.md;
    ".claude/commands/orchestrate.md".source = ./config/claude/commands/orchestrate.md;

    # MCP wrapper scripts
    ".claude/scripts/figma-mcp-wrapper.sh" = {
      source = ./config/claude/figma-mcp-wrapper.sh;
      executable = true;
    };

    # Specialist agents
    ".claude/agents/orchestrator.md".source = ./config/claude/agents/orchestrator.md;
    ".claude/agents/frontend-developer.md".source = ./config/claude/agents/frontend-developer.md;
    ".claude/agents/backend-developer.md".source = ./config/claude/agents/backend-developer.md;
    ".claude/agents/database-specialist.md".source = ./config/claude/agents/database-specialist.md;
    ".claude/agents/ui-ux-designer.md".source = ./config/claude/agents/ui-ux-designer.md;
    ".claude/agents/security-auditor.md".source = ./config/claude/agents/security-auditor.md;
    ".claude/agents/documentation-expert.md".source = ./config/claude/agents/documentation-expert.md;
    ".claude/agents/architect.md".source = ./config/claude/agents/architect.md;
    ".claude/agents/rust-developer.md".source = ./config/claude/agents/rust-developer.md;
    ".claude/agents/dart-developer.md".source = ./config/claude/agents/dart-developer.md;
    ".claude/agents/nix-specialist.md".source = ./config/claude/agents/nix-specialist.md;
    ".claude/agents/code-reviewer.md".source = ./config/claude/agents/code-reviewer.md;
    ".claude/agents/test-engineer.md".source = ./config/claude/agents/test-engineer.md;
  };
}
