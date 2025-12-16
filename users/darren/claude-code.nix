{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  home.file = {
    # Global memory storage directory
    ".local/share/claude-memory/.keep".text = "";

    # Project guidelines
    ".claude/CLAUDE.md".source = ./config/claude/CLAUDE.md;

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
  };
}
