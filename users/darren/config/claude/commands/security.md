---
description: Security-focused audit (OWASP, secrets, auth)
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(find:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Security Audit

Perform a security-focused audit of the codebase. This command is **read-only** - it will NOT modify any files.

Target: $ARGUMENTS

If no argument provided, audit the entire codebase. You can specify:
- A file or directory: `/security src/auth/`
- A specific concern: `/security secrets` or `/security injection`
- An OWASP category: `/security A01` (Broken Access Control)

## Analysis Areas

### 1. Secrets Detection
Search for patterns that indicate hardcoded secrets:
- API keys, tokens, passwords
- Private keys, certificates
- Connection strings
- AWS/GCP/Azure credentials
- JWT secrets

Patterns to search:
```
password\s*=
api[_-]?key\s*=
secret\s*=
token\s*=
-----BEGIN.*PRIVATE KEY-----
AKIA[0-9A-Z]{16}
```

### 2. OWASP Top 10

#### A01: Broken Access Control
- Missing authorization checks
- Direct object references
- CORS misconfigurations

#### A02: Cryptographic Failures
- Weak encryption algorithms
- Hardcoded keys
- Missing encryption for sensitive data

#### A03: Injection
- SQL injection risks
- Command injection
- XSS vulnerabilities
- Template injection

#### A04: Insecure Design
- Missing input validation
- Business logic flaws
- Missing rate limiting

#### A05: Security Misconfiguration
- Debug mode in production
- Default credentials
- Verbose error messages
- Missing security headers

#### A06: Vulnerable Components
- Outdated dependencies
- Known vulnerable packages

#### A07: Authentication Failures
- Weak password policies
- Missing MFA considerations
- Session management issues

#### A08: Software/Data Integrity
- Missing integrity checks
- Unsigned updates
- Untrusted deserialization

#### A09: Logging Failures
- Missing security logging
- Sensitive data in logs
- No audit trail

#### A10: SSRF
- Unvalidated URLs
- Internal network access risks

### 3. Authentication & Authorization
- Auth implementation patterns
- Token handling
- Session management
- Permission checks

### 4. Input Validation
- User input handling
- File upload validation
- Data sanitization

## Output Format

### Security Audit Report

#### Summary
- Critical vulnerabilities: X
- High severity: X
- Medium severity: X
- Low severity: X

#### Critical Findings
Must be fixed immediately:

**[CRITICAL-001] Finding Title**
- **Location**: file:line
- **Category**: OWASP category
- **Description**: What was found
- **Risk**: What could happen
- **Remediation**: How to fix

#### High Severity Findings
Should be fixed before deployment:
[Same format as above]

#### Medium Severity Findings
Should be fixed in near term:
[Same format as above]

#### Low Severity Findings
Consider fixing:
[Same format as above]

#### Security Checklist
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Authentication implemented correctly
- [ ] Authorization checks in place
- [ ] Sensitive data encrypted
- [ ] Dependencies up to date
- [ ] Security headers configured
- [ ] Error handling doesn't leak info

#### Recommendations
Prioritized list of security improvements.
