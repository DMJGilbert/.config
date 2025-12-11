{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  home.file = {
    # Project guidelines
    ".claude/CLAUDE.md".source = ./config/claude/CLAUDE.md;

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
  };
}
