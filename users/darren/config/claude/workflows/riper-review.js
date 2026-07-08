export const meta = {
  name: "riper-review",
  description:
    "RIPER REVIEW phase — security, bug, and quality reviewers in parallel; Critical/High findings adversarially verified before reporting",
  whenToUse:
    "REVIEW phase of RIPER on a branch or working-tree change set. Pass a git ref as args to review <ref>...HEAD.",
  phases: [
    { title: "Scope", detail: "resolve diff scope and changed files" },
    {
      title: "Review",
      detail: "security-reviewer, bug-hunter, quality-reviewer in parallel",
    },
    {
      title: "Verify",
      detail: "adversarial check of each Critical/High finding",
    },
  ],
};

// Canonical severity rubric (agents/*.md reference this file for it).
const RUBRIC = `Severity rubric:
- critical: active exploit path, data loss, production-breaking. Block merge.
- high: confirmed bug or vulnerability with significant impact. Fix before merge.
- medium: notable concern (performance, maintainability, edge case). Normal cycle.
- low: minor improvement, informational.`;

const SCOPE_SCHEMA = {
  type: "object",
  required: ["description", "files"],
  properties: {
    description: {
      type: "string",
      description: "which diff scope was used and why",
    },
    files: { type: "array", items: { type: "string" } },
    stat: { type: "string", description: "output of git diff --stat" },
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
        required: ["title", "severity", "file", "description", "evidence"],
        properties: {
          title: { type: "string" },
          severity: { enum: ["critical", "high", "medium", "low"] },
          file: { type: "string" },
          line: { type: "number" },
          description: { type: "string" },
          evidence: {
            type: "string",
            description: "verbatim code excerpt, not a paraphrase",
          },
          fix: { type: "string" },
        },
      },
    },
  },
};

const VERDICT_SCHEMA = {
  type: "object",
  required: ["verdict", "reasoning"],
  properties: {
    verdict: { enum: ["confirmed", "refuted", "uncertain"] },
    reasoning: { type: "string" },
  },
};

phase("Scope");
const ref = typeof args === "string" && args.trim() ? args.trim() : null;
const scope = await agent(
  `Determine the review scope for the current git repo. ${
    ref
      ? `Use \`git diff ${ref}...HEAD\`.`
      : "If the current branch is not main/master, use `git diff main...HEAD`. Otherwise use uncommitted changes: `git diff HEAD` plus relevant untracked files."
  } Return the scope description, the changed file list, and the diff stat. Do not review the code yet.`,
  { label: "resolve-scope", phase: "Scope", schema: SCOPE_SCHEMA },
);
if (!scope || !scope.files.length) {
  return { error: "No changes found to review", scope };
}
log(`Reviewing ${scope.files.length} files: ${scope.description}`);

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
];

// Each reviewer's Critical/High findings go to verification as soon as that
// reviewer finishes — no barrier between Review and Verify.
const results = await pipeline(
  REVIEWERS,
  (r) =>
    agent(
      `Review the following change set for ${r.focus} ONLY.

Scope: ${scope.description}
Changed files:
${scope.files.join("\n")}
${scope.stat ? `\nDiff stat:\n${scope.stat}` : ""}

Read the changed files and review the current code. ${RUBRIC}

A review with zero findings is a legitimate outcome — do not pad with
speculative or trivial findings. Every critical/high finding must quote the
offending code verbatim in \`evidence\`.`,
      {
        agentType: r.agentType,
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
${f.evidence}`,
            {
              label: `verify:${f.file}`,
              phase: "Verify",
              effort: "high",
              schema: VERDICT_SCHEMA,
            },
          ).then((v) => ({
            ...f,
            reviewer: r.key,
            verdict: v ? v.verdict : "uncertain",
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
);

const perReviewer = results.filter(Boolean);
const verified = perReviewer.flatMap((r) => r.verified);

return {
  scope,
  reviewers_completed: perReviewer.map((r) => r.reviewer),
  confirmed: verified.filter((f) => f.verdict === "confirmed"),
  uncertain: verified.filter((f) => f.verdict === "uncertain"),
  refuted_dropped: verified
    .filter((f) => f.verdict === "refuted")
    .map((f) => ({
      title: f.title,
      reviewer: f.reviewer,
      reason: f.verdict_reasoning,
    })),
  medium_low: perReviewer.flatMap((r) => r.medium_low),
  report_instructions:
    'Format as "RIPER Review" with sections: Critical/High (confirmed, with reviewer attribution), Uncertain (needs human judgement), Medium/Low (unverified), Refuted (dropped, one line each), and an Overall Assessment ending with a merge recommendation: ready / needs fixes / block. If a reviewer is missing from reviewers_completed, flag the coverage gap.',
};
