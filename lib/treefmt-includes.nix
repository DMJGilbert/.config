# Shared treefmt formatter include lists.
# Single source of truth used by:
#   - flake.nix  treefmtEval     (for `nix fmt` and pre-commit hooks)
#   - users/darren/home-manager.nix  (~/treefmt.toml for non-flake projects)
{
  prettier = [
    "*.json"
    "*.yaml"
    "*.yml"
    "*.md"
    "*.ts"
    "*.tsx"
    "*.js"
    "*.css"
    "*.html"
  ];
}
