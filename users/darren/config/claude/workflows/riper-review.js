export const meta = {
  name: "riper-review",
  description:
    "RIPER REVIEW phase — security, bug, quality, and intent/style reviewers in parallel, plus lint/typecheck triage; Critical/High findings adversarially verified and baseline-checked before reporting",
  whenToUse:
    "REVIEW phase of RIPER on a branch or working-tree change set. Pass a git ref as args to review <ref>...HEAD.",
  phases: [
    {
      title: "Scope",
      detail: "resolve diff scope, branch intent, prior review",
    },
    { title: "Tooling", detail: "run lint and typecheck, triage diagnostics" },
    {
      title: "Review",
      detail: "security, bug, quality, and intent/style reviewers in parallel",
    },
    {
      title: "Verify",
      detail:
        "adversarial check + baseline check of each Critical/High finding",
    },
  ],
};

// Canonical severity rubric (agents/*.md reference this file for it).
const RUBRIC = `Severity rubric:
- critical: active exploit path, data loss, production-breaking. Block merge.
- high: confirmed bug or vulnerability with significant impact. Fix before merge.
- medium: notable concern (performance, maintainability, edge case). Normal cycle.
- low: minor improvement, informational.`;

const CATEGORIES = `Category (exactly one per finding):
- logic: incorrect behaviour, security holes, edge cases, race conditions, missing error handling.
- style: deviations from the established conventions of this repository, naming, formatting the
  formatter does not cover, spelling mistakes in identifiers/comments/user-facing strings.
- other: performance, maintainability, test-coverage gaps, tooling/config gaps, anything else.`;

const SCOPE_SCHEMA = {
  type: "object",
  required: ["description", "files", "base_ref", "branch", "intent"],
  properties: {
    description: {
      type: "string",
      description: "which diff scope was used and why",
    },
    base_ref: {
      type: "string",
      description: "the base ref the diff is against",
    },
    branch: { type: "string" },
    intent: {
      type: "string",
      description:
        "inferred purpose of the branch, from branch name and commit subjects",
    },
    commits: { type: "array", items: { type: "string" } },
    files: { type: "array", items: { type: "string" } },
    stat: { type: "string", description: "output of git diff --stat" },
    uncommitted: {
      type: "string",
      description:
        "summary of uncommitted working-tree and untracked changes, or 'none'",
    },
    timestamp: { type: "string", description: "output of `date -Iseconds`" },
    lint_command: { type: "string", description: "empty string if none found" },
    check_command: {
      type: "string",
      description: "typecheck/build-check command; empty string if none found",
    },
    tool_coverage: {
      type: "string",
      description:
        "which changed files are NOT covered by lint/typecheck config paths, and why",
    },
    prior_review: {
      type: "object",
      description: "parsed review.md if present at the repo root",
      properties: {
        exists: { type: "boolean" },
        branch: { type: "string" },
        iterations: { type: "number" },
        head_advanced: {
          type: "boolean",
          description: "whether new commits exist since the prior review",
        },
        issues: {
          type: "array",
          items: {
            type: "object",
            properties: {
              number: { type: "number" },
              title: { type: "string" },
              file: { type: "string" },
              severity: { type: "string" },
            },
          },
        },
      },
    },
  },
};

const FINDINGS_SCHEMA = {
  type: "object",
  required: ["scope_reviewed", "findings"],
  properties: {
    scope_reviewed: {
      type: "string",
      description: "exactly what was reviewed (files/diff scope)",
    },
    findings: {
      type: "array",
      items: {
        type: "object",
        required: [
          "title",
          "severity",
          "category",
          "file",
          "description",
          "evidence",
        ],
        properties: {
          title: { type: "string" },
          severity: { enum: ["critical", "high", "medium", "low"] },
          category: { enum: ["logic", "style", "other"] },
          file: { type: "string" },
          line: {
            type: "number",
            description:
              "verified with `grep -n` against the current file, NOT inferred from diff hunk offsets",
          },
          description: { type: "string" },
          evidence: {
            type: "string",
            description: "verbatim code excerpt, not a paraphrase",
          },
          suspected_pre_existing: {
            type: "boolean",
            description: "reviewer believes this also exists on the base ref",
          },
          fix: { type: "string" },
        },
      },
    },
  },
};

const DIAGNOSTICS_SCHEMA = {
  type: "object",
  required: ["ran", "findings"],
  properties: {
    ran: {
      type: "string",
      description: "the commands actually run, or why none were run",
    },
    preconditions_ok: {
      type: "boolean",
      description:
        "false if dependencies are not installed / toolchain unavailable, making the run meaningless",
    },
    findings: FINDINGS_SCHEMA.properties.findings,
  },
};

const VERDICT_SCHEMA = {
  type: "object",
  required: ["verdict", "reasoning", "pre_existing"],
  properties: {
    verdict: { enum: ["confirmed", "refuted", "uncertain"] },
    reasoning: { type: "string" },
    pre_existing: {
      enum: ["new", "pre-existing", "latent-exposed", "unknown"],
      description:
        "new = introduced by this branch; pre-existing = present on the base ref too; latent-exposed = existed but is only reachable/visible because of this branch's changes",
    },
    line: {
      type: "number",
      description: "grep-verified line number in the current file",
    },
  },
};

const PRIOR_STATUS_SCHEMA = {
  type: "object",
  required: ["statuses"],
  properties: {
    statuses: {
      type: "array",
      items: {
        type: "object",
        required: ["number", "title", "status"],
        properties: {
          number: { type: "number" },
          title: { type: "string" },
          status: { enum: ["fixed", "unchanged", "partially-improved"] },
          note: { type: "string" },
        },
      },
    },
  },
};

phase("Scope");
const ref = typeof args === "string" && args.trim() ? args.trim() : null;
const scope = await agent(
  `Determine the review scope for the current git repo. Do not review the code yet —
this step only gathers context. Run the git and shell commands you need in as few
batched Bash calls as possible.

1. Base ref. ${
    ref
      ? `Use \`${ref}\` as the base ref.`
      : "If the current branch is not the default branch, diff against the default branch (check for `develop` first, then `main`/`master` — use whichever exists and is the actual integration branch for this repo). If the current branch IS the default branch, review uncommitted changes instead: `git diff HEAD` plus relevant untracked files."
  }
2. Diff. Use two-dot syntax with lockfiles excluded:
   \`git diff <base>..HEAD --stat -- ':!*lock.json' ':!*.lock' ':!yarn.lock' ':!pnpm-lock.yaml' ':!flake.lock' ':!Cargo.lock'\`
   Two dots, not three — three-dot combined with pathspec exclusions silently
   produces no output on some git versions. If the exclusion form yields nothing,
   re-run without pathspecs and filter lockfiles out of the file list yourself.
3. Branch name and \`git log <base>..HEAD --oneline\`. From the branch name and the
   commit subjects, infer the *intent* of the branch in one or two sentences.
4. Uncommitted work: \`git status --short\` and \`git diff --stat HEAD\`. Any
   uncommitted or untracked changes are the latest state of the branch and are IN
   SCOPE — include those files in the file list. Do not trust any stale status
   snapshot; run the commands.
5. Toolchain. Read the project manifest (package.json / Cargo.toml / pubspec.yaml /
   flake.nix / Makefile, whichever applies) and identify the lint command and the
   type/static-check command, preferring named scripts (e.g. \`npm run lint\`,
   \`npm run check\`) over raw invocations. Return empty strings if none exist. If the
   lint script already runs the type checker, return only the lint command.
   Also verify the toolchain can actually run (e.g. \`test -d node_modules\`); if
   dependencies are not installed, say so in \`tool_coverage\`.
6. Coverage gaps. Read the checker config (tsconfig \`include\`, eslint globs, Cargo
   workspace members, etc.) and report which changed files fall OUTSIDE those paths.
   Findings in those files will not be caught by tooling and need manual review.
7. Prior review: read \`review.md\` at the repo root if it exists (silently skip if
   not). Return its branch, its iteration count, and its issue list. Set
   \`head_advanced\` by comparing the commits it records against the current
   \`git log <base>..HEAD --oneline\`.
8. Run \`date -Iseconds\` and return it as \`timestamp\`.`,
  { label: "resolve-scope", phase: "Scope", schema: SCOPE_SCHEMA },
);
if (!scope || !scope.files.length) {
  return { error: "No changes found to review", scope };
}
log(`Reviewing ${scope.files.length} files: ${scope.description}`);
log(`Branch intent: ${scope.intent}`);
if (scope.prior_review && scope.prior_review.exists) {
  log(
    `Prior review found (iteration ${scope.prior_review.iterations || 1}); HEAD advanced: ${scope.prior_review.head_advanced}`,
  );
}

const SCOPE_BRIEF = `Scope: ${scope.description}
Base ref: ${scope.base_ref}
Branch: ${scope.branch}
Inferred branch intent: ${scope.intent}
Changed files (includes uncommitted work — review the current on-disk state):
${scope.files.join("\n")}
${scope.stat ? `\nDiff stat:\n${scope.stat}` : ""}
${scope.uncommitted && scope.uncommitted !== "none" ? `\nUncommitted changes:\n${scope.uncommitted}` : ""}
${scope.tool_coverage ? `\nTooling coverage note:\n${scope.tool_coverage}` : ""}`;

const REVIEW_RULES = `Read the changed files and review the current code. ${RUBRIC}

${CATEGORIES}

A review with zero findings is a legitimate outcome — do not pad with
speculative or trivial findings. Every critical/high finding must quote the
offending code verbatim in \`evidence\`.

Line numbers: never infer a line number from a diff hunk offset — they are
routinely wrong by 5-20 lines. Confirm every reported line with \`grep -n\` or a
targeted read of the current file before reporting it. If you cannot confirm a
line, omit the field rather than guessing.

If you believe a problem also exists unchanged on \`${scope.base_ref}\`, still report it
but set \`suspected_pre_existing\`.

Files listed as outside tooling coverage get no lint or type checking at all —
review those by hand for the issues a checker would otherwise catch.`;

const REVIEWERS = [
  {
    key: "security",
    agentType: "security-reviewer",
    focus:
      "security vulnerabilities, auth gaps, injection risks, secrets exposure, OWASP Top 10",
  },
  {
    key: "bugs",
    agentType: "bug-hunter",
    focus:
      "logic errors, edge cases, race conditions, null handling issues, off-by-one errors",
  },
  {
    key: "quality",
    agentType: "quality-reviewer",
    focus:
      "performance issues, maintainability problems, code smells, test coverage gaps",
  },
  {
    key: "intent",
    // No agentType: this reviewer needs Bash for git archaeology against the base ref.
    focus: `deviation from the stated branch intent, deviation from the established
conventions of this repository, and spelling mistakes in identifiers, comments,
commit-visible strings and user-facing text.

You have git access — additionally check for code that is BEHIND the base ref:
a fix landed on \`${scope.base_ref}\` after this branch was cut and this branch still
carries the old, broken version, or the merge resolved in favour of the stale
side. Use \`git log ${scope.base_ref} -- <file>\` and \`git diff HEAD..${scope.base_ref} -- <file>\`
on the changed files to spot it. Report each as a regression relative to
\`${scope.base_ref}\` that must be resolved before merge.

For repository conventions, read two or three comparable untouched files in the
same area and compare — do not assert a convention you have not observed.`,
  },
];

// Lint/typecheck runs concurrently with the reviewers so a slow lint never gates
// the review; its diagnostics are merged into the findings at the end.
const [diagnostics, results, priorStatus] = await parallel([
  () =>
    scope.lint_command || scope.check_command
      ? agent(
          `Run this project's checkers and triage the output into review findings.

Commands to run (skip any that is empty), in ONE batched Bash call:
${scope.lint_command ? `- lint: ${scope.lint_command}` : ""}
${scope.check_command ? `- check: ${scope.check_command}` : ""}

${scope.tool_coverage ? `Toolchain/coverage note from scoping:\n${scope.tool_coverage}\n` : ""}
These can take several minutes; allow a generous timeout. If the toolchain cannot
run (dependencies not installed, missing binary), set \`preconditions_ok\` to false,
say so in \`ran\`, and return no findings rather than guessing.

Report each diagnostic as a finding. Trust the checker — do not write ad-hoc
scripts to re-verify behaviour the type checker has already flagged.

${RUBRIC}

${CATEGORIES}

Diagnostics on lines the diff did not touch are usually latent problems newly
exposed by this branch (stricter types from a newly imported module, a new call
site). Report them, note they are latent-but-exposed in the description, and keep
the severity based on impact — the fix still belongs in this branch before merge.
Pre-existing noise unrelated to the changed files should be summarised in one
low-severity finding, not enumerated.

Set \`line\` only from the checker's own reported line number.`,
          {
            label: "lint+typecheck",
            phase: "Tooling",
            schema: DIAGNOSTICS_SCHEMA,
          },
        )
      : Promise.resolve({
          ran: "no lint or check command found for this project",
          preconditions_ok: true,
          findings: [],
        }),

  // Each reviewer's Critical/High findings go to verification as soon as that
  // reviewer finishes — no barrier between Review and Verify.
  () =>
    pipeline(
      REVIEWERS,
      (r) =>
        agent(
          `Review the following change set for ${r.focus}

ONLY the above concern — the other reviewers cover the rest.

${SCOPE_BRIEF}

${REVIEW_RULES}`,
          {
            ...(r.agentType ? { agentType: r.agentType } : {}),
            label: `review:${r.key}`,
            phase: "Review",
            schema: FINDINGS_SCHEMA,
          },
        ),
      (review, r) => {
        if (!review) return null;
        const findings = review.findings || [];
        const critHigh = findings.filter(
          (f) => f.severity === "critical" || f.severity === "high",
        );
        return parallel(
          critHigh.map(
            (f) => () =>
              agent(
                `Adversarially verify this ${f.severity} code-review finding. Your job
is to REFUTE it if you can — read the code at ${f.file}${f.line ? `:${f.line}` : ""},
check the claimed behaviour, and look for guards, callers, or context the
reviewer may have missed. Default to 'uncertain' rather than 'confirmed' if
you cannot demonstrate the failure.

Finding: ${f.title}
Description: ${f.description}
Evidence quoted by reviewer:
${f.evidence}

Then establish attribution with git, and set \`pre_existing\`:
- \`git show ${scope.base_ref}:${f.file}\` (or \`git diff ${scope.base_ref}..HEAD -- ${f.file}\`)
  to see whether the offending code is unchanged on the base ref.
- "pre-existing" if the same defect is present and equally reachable on
  \`${scope.base_ref}\`; "latent-exposed" if the code predates the branch but this
  branch is what makes it reachable, incorrect, or type-invalid; "new" if this
  branch introduced it. Use "unknown" only if git cannot settle it.
  ${f.suspected_pre_existing ? "The reviewer suspects this is pre-existing — confirm or refute that." : ""}

Finally, confirm the line number with \`grep -n\` against the current file and
return the verified value in \`line\` (omit it if you cannot confirm one).`,
                {
                  label: `verify:${f.file}`,
                  phase: "Verify",
                  effort: "high",
                  schema: VERDICT_SCHEMA,
                },
              ).then((v) => ({
                ...f,
                reviewer: r.key,
                line: v && v.line ? v.line : f.line,
                verdict: v ? v.verdict : "uncertain",
                pre_existing: v ? v.pre_existing : "unknown",
                verdict_reasoning: v ? v.reasoning : "verifier unavailable",
              })),
          ),
        ).then((verified) => ({
          reviewer: r.key,
          scope_reviewed: review.scope_reviewed,
          verified: verified.filter(Boolean),
          medium_low: findings
            .filter((f) => f.severity === "medium" || f.severity === "low")
            .map((f) => ({ ...f, reviewer: r.key })),
        }));
      },
    ),

  () => {
    const prior = scope.prior_review;
    if (!prior || !prior.exists || !prior.issues || !prior.issues.length) {
      return Promise.resolve(null);
    }
    if (prior.branch && scope.branch && prior.branch !== scope.branch) {
      return Promise.resolve(null);
    }
    return agent(
      `A prior review of this same branch is recorded in \`review.md\` at the repo root.
For each issue below, determine its CURRENT status: fixed, unchanged, or
partially-improved. Verify against the code on disk with one batched set of
targeted \`grep -n\` / offset-limited reads — one lookup per issue, batched into as
few calls as possible.

Grep caveat: \`{\` and \`}\` are regex metacharacters, so JSX-style patterns such as
\`onClick={handler}\` silently match nothing. Escape them or search for the bare
identifier. When confirming the exact content of a known line, a targeted read
beats a grep.

Do not re-review the branch and do not report new issues — status only.

Prior issues:
${prior.issues
  .map(
    (i) =>
      `#${i.number} [${i.severity || "?"}] ${i.title} — ${i.file || "unknown file"}`,
  )
  .join("\n")}`,
      {
        label: "prior-issue-status",
        phase: "Verify",
        schema: PRIOR_STATUS_SCHEMA,
      },
    );
  },
]);

const perReviewer = (results || []).filter(Boolean);
const verified = perReviewer.flatMap((r) => r.verified);
const diag = diagnostics || {
  ran: "tooling agent failed",
  preconditions_ok: false,
  findings: [],
};
const diagFindings = (diag.findings || []).map((f) => ({
  ...f,
  reviewer: "tooling",
}));

const missingReviewers = REVIEWERS.map((r) => r.key).filter(
  (k) => !perReviewer.some((r) => r.reviewer === k),
);

return {
  scope: {
    description: scope.description,
    base_ref: scope.base_ref,
    branch: scope.branch,
    intent: scope.intent,
    files: scope.files,
    uncommitted: scope.uncommitted,
    tool_coverage: scope.tool_coverage,
    timestamp: scope.timestamp,
  },
  reviewers_completed: perReviewer.map((r) => r.reviewer),
  reviewers_missing: missingReviewers,
  tooling: {
    ran: diag.ran,
    preconditions_ok: diag.preconditions_ok !== false,
    finding_count: diagFindings.length,
  },
  confirmed: verified.filter((f) => f.verdict === "confirmed"),
  uncertain: verified.filter((f) => f.verdict === "uncertain"),
  refuted_dropped: verified
    .filter((f) => f.verdict === "refuted")
    .map((f) => ({
      title: f.title,
      reviewer: f.reviewer,
      reason: f.verdict_reasoning,
    })),
  medium_low: perReviewer
    .flatMap((r) => r.medium_low)
    .concat(
      diagFindings.filter(
        (f) => f.severity === "medium" || f.severity === "low",
      ),
    ),
  tooling_high: diagFindings.filter(
    (f) => f.severity === "critical" || f.severity === "high",
  ),
  prior_issue_status: priorStatus ? priorStatus.statuses : null,
  prior_review_iterations:
    scope.prior_review && scope.prior_review.exists
      ? (scope.prior_review.iterations || 1) + 1
      : 1,
  report_instructions: `Write the review to \`review.md\` at the repository root, replacing any existing
file. Do not modify any other file, and do not fix any of the issues — this is a
review only.

\`review.md\` structure, in this order:
1. Header: the branch reviewed, the base ref, the timestamp from \`scope.timestamp\`,
   and the review iteration number (\`prior_review_iterations\`).
2. The inferred intent of the branch (\`scope.intent\`).
3. A brief summary: number of issues and overall quality.
4. If \`prior_issue_status\` is non-null, a "Since last review" table of each prior
   issue number, title and its status (fixed / unchanged / partially improved).
5. The issues, grouped into "Logical Errors" (category \`logic\`), "Style Compliance"
   (category \`style\`) and "Other" (category \`other\`). Omit any empty category —
   never render an empty table. Within each category sort by severity
   (critical > high > medium > low). Number every issue sequentially across the
   whole document so it can be referenced in the next iteration. Each category
   opens with a summary table (number, short description, full path and line,
   severity) and is followed by the detailed explanation of each issue.
   Mark each issue's provenance from \`pre_existing\`: new / pre-existing on the base
   ref / latent bug exposed by this branch. Pre-existing issues are reported but
   must not be attributed to this branch; latent-exposed issues still need fixing
   in this branch before merge.
6. If no issues were found in any category, render no tables at all — write a
   single paragraph confirming the result and stating the branch is clean.

Then report to the user in chat as "RIPER Review": the branch intent, the issue
count and overall quality, the Critical/High confirmed findings with reviewer
attribution, Uncertain findings needing human judgement, a one-line-each list of
Refuted (dropped) findings, and an Overall Assessment ending with a merge
recommendation: ready / needs fixes / block. Flag coverage gaps explicitly if
\`reviewers_missing\` is non-empty, if \`tooling.preconditions_ok\` is false, or if
\`scope.tool_coverage\` reports changed files outside lint/typecheck paths.`,
};
