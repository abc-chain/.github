# Repository improvement plan

Status: **READY FOR OWNER REVIEW — NOT IMPLEMENTATION APPROVAL**
Repository: `abc-chain/.github`
Priority: low, consistency hardening
Plan owner: `@2systemadmin`

This is a temporary, owner-requested proposal for the next Claude/Codex session.
Read `AGENTS.md` first. This plan does not override CODEOWNERS, security rules,
or GitHub permissions. Its presence is not permission to implement the checklist
or change organization settings; the current user request must approve the work.

## Why this repository is different

This is the public GitHub-special repository for organization community-health
defaults. Its current layout is correct:

```text
.github (public)
├── root community files       -> inherited by repositories that omit them
├── .github/ISSUE_TEMPLATE/    -> organization issue forms
├── profile/README.md          -> organization profile
├── workflow-templates/        -> "New workflow" starter files
└── scripts/                   -> local public-safe validation
```

Do not turn this into an application layout. In particular, do not create
`src/`, `tests/`, or `infra/` merely for symmetry with software repositories.

## Handoff wiring installed with this plan

- [x] Add `CLAUDE.md` as a minimal import of `AGENTS.md`.
- [x] Add `.github/copilot-instructions.md` as a minimal pointer to `AGENTS.md`.
- [x] Tell agents in `AGENTS.md` to read this plan for relevant work.
- [x] Route changes to this plan to `@2systemadmin` in CODEOWNERS.

## Safe implementation work

- [ ] Update `scripts/validate.sh` to require `CLAUDE.md` and
      `.github/copilot-instructions.md` and verify both point to `AGENTS.md`.
- [ ] Briefly document the canonical agent entry points in `README.md`.
- [ ] Keep the validation local and public-safe; do not make the repository's
      own baseline workflow call a private reusable workflow.
- [ ] Run every validation command below and attach results to a focused PR.
- [ ] After merge, verify the hosted checks and CODEOWNERS parse result.

No existing file or directory should move. The expected subsequent
implementation diff is limited to:

```text
README.md                              wording only
scripts/validate.sh                    two entry-point assertions
REPOSITORY_IMPROVEMENT_PLAN.md         checklist/evidence only
```

## Public-content boundary

Everything in this repository is publicly readable. Never include internal
contacts, non-public repository inventory, invitation details, customer data,
credentials, private architecture, or vulnerability details. References to
the documented organization name and public contribution process are fine.

## Owner-decision gates

Stop and ask `@2systemadmin` before any of the following:

- changing repository visibility, organization settings, permissions, teams,
  rulesets, or workflow tags;
- changing the versions used by workflow starters;
- introducing central policy code or access to private reusable workflows;
- forbidding all PEM files (a PEM may be a public certificate);
- moving a GitHub-supported community file from its current path.

The conservative default is to leave those items unchanged.

## Explicit non-goals

- Do not make this repository private; its organization defaults require public
  visibility to work as intended across the account plan.
- Do not add `.abc/repository-policy.json` until a separately reviewed public,
  locally enforceable policy design exists.
- Do not copy private central policy implementation into this repository.
- Do not rewrite workflow starters in this maintenance task.
- Do not add application scaffolding or empty directories.
- Do not add secrets, access tokens, invitations, or private URLs.

## Validation

Run from the repository root:

```bash
git diff --check
bash scripts/validate.sh
bash scripts/security-scan.sh
git grep -n 'AGENTS.md' -- CLAUDE.md .github/copilot-instructions.md
! rg -n 'uses:\s*abc-chain/abc-workflows/\.github/workflows/' .github/workflows
```

After pushing the implementation branch:

```bash
gh api "repos/abc-chain/.github/codeowners/errors?ref=$(git rev-parse HEAD)"
gh pr checks --repo abc-chain/.github --required
```

The negative `rg` check applies only to this public repository's own workflows;
versioned starter references under `workflow-templates/` are intentionally
copied into future private repositories. After an owner-authorized merge, assert
the latest main baseline completed successfully:

```bash
test "$(gh run list --repo abc-chain/.github --branch main --workflow baseline.yml --limit 1 --json conclusion --jq '.[0].conclusion')" = success
```

Acceptance criteria:

- [ ] `.github` remains public.
- [ ] No community, profile, template, or script path moved.
- [ ] Claude and Copilot resolve to canonical `AGENTS.md`.
- [ ] Local validation requires both instruction shims.
- [ ] No private reusable workflow is called by the public baseline.
- [ ] No confidential content or credential was introduced.
- [ ] GitHub reports no CODEOWNERS syntax errors.
- [ ] Hosted baseline checks pass.

## Completion and cleanup

The implementation agent pushes a focused branch, opens a PR, records its URL
and branch CI, and stops. Only `@2systemadmin` may authorize merge. After owner
acceptance, a cleanup PR removes this plan, its CODEOWNERS entry, the temporary
AGENTS paragraph, and unnecessary plan-specific shim wording while preserving
canonical AGENTS -> Claude/Copilot linkage. Record the merge SHA and post-merge
main run in the cleanup PR description rather than editing an already-merged
plan solely to append evidence.
