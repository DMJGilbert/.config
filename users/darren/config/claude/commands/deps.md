---
description: Dependency audit (outdated, vulnerabilities, licenses)
allowed-tools:
  - Bash(npm outdated:*)
  - Bash(npm ls:*)
  - Bash(npm audit:*)
  - Bash(yarn outdated:*)
  - Bash(pnpm outdated:*)
  - Bash(cargo outdated:*)
  - Bash(cargo audit:*)
  - Bash(cargo tree:*)
  - Bash(nix flake info:*)
  - Bash(nix flake metadata:*)
  - Bash(pod outdated:*)
  - Bash(swift package show-dependencies:*)
  - Bash(pip list --outdated:*)
  - Bash(find:*)
  - Bash(cat:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Dependency Audit

Audit project dependencies for updates, vulnerabilities, and license compliance. This command is **read-only** - it will NOT modify any files or update packages.

Target: $ARGUMENTS

If no argument provided, audit all detected ecosystems. You can specify:
- An ecosystem: `/deps npm` or `/deps cargo` or `/deps nix`
- A specific check: `/deps vulnerabilities` or `/deps outdated` or `/deps licenses`
- A package: `/deps lodash` - Check specific package status

## Auto-Detection

Detect package ecosystems by looking for:
- `package.json` / `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` → npm/yarn/pnpm
- `Cargo.toml` / `Cargo.lock` → Rust/Cargo
- `flake.nix` / `flake.lock` → Nix
- `Podfile` / `Podfile.lock` → CocoaPods
- `Package.swift` → Swift Package Manager
- `requirements.txt` / `pyproject.toml` / `poetry.lock` → Python
- `go.mod` / `go.sum` → Go
- `Gemfile` / `Gemfile.lock` → Ruby

## Analysis Steps

### 1. Detect Ecosystems
```bash
find . -maxdepth 3 -name "package.json" -o -name "Cargo.toml" -o -name "flake.nix" -o -name "Podfile" -o -name "Package.swift" -o -name "requirements.txt" -o -name "go.mod"
```

### 2. Check Outdated Packages
Run appropriate commands for each detected ecosystem:
- npm: `npm outdated`
- cargo: `cargo outdated` (if available)
- nix: Check flake inputs against latest

### 3. Security Vulnerabilities
- npm: `npm audit`
- cargo: `cargo audit` (if available)
- Check known vulnerability databases

### 4. License Compliance
- Identify all licenses in dependency tree
- Flag potential issues (GPL in MIT project, etc.)
- List uncommon or unknown licenses

### 5. Unused Dependencies
- Look for imported but unused packages
- Check for phantom dependencies

## Output Format

### Dependency Audit Report

#### Summary
| Ecosystem | Total | Outdated | Vulnerable | Issues |
|-----------|-------|----------|------------|--------|
| npm | X | X | X | X |
| cargo | X | X | X | X |
| nix | X | X | X | X |

#### Outdated Packages

##### Critical Updates (Security)
| Package | Current | Latest | Severity |
|---------|---------|--------|----------|
| example | 1.0.0 | 2.0.0 | Critical |

##### Major Updates (Breaking)
| Package | Current | Latest | Notes |
|---------|---------|--------|-------|
| example | 1.0.0 | 2.0.0 | [changelog link] |

##### Minor/Patch Updates
| Package | Current | Latest |
|---------|---------|--------|
| example | 1.0.0 | 1.1.0 |

#### Security Vulnerabilities
| Package | Severity | CVE | Description | Fix Version |
|---------|----------|-----|-------------|-------------|
| example | High | CVE-XXX | Description | 1.2.3 |

#### License Report
| License | Count | Packages |
|---------|-------|----------|
| MIT | X | pkg1, pkg2 |
| Apache-2.0 | X | pkg3 |
| GPL-3.0 | X | **pkg4** (review needed) |

#### Potentially Unused
- `package-name` - No imports found
- `other-package` - Only in devDependencies but not used

#### Recommendations
1. **[Critical]** Update X to fix security vulnerability
2. **[High]** Review GPL dependency for compatibility
3. **[Medium]** Update major versions of Y, Z
4. **[Low]** Clean up unused dependencies

#### Update Commands
```bash
# Security fixes (run these first)
npm update package-name

# Major updates (test thoroughly)
npm install package-name@latest
```

**Remember**: This is an audit only. Do NOT run update commands automatically.
