# abc repository standard

This document is the concise operating baseline for repositories owned by
`abc-chain`. “Must” items are policy; “should” items are defaults that may be
adapted with a documented reason.

## Classify before structuring

Every active repository must have accurate `repo_type`, `criticality`,
`owner_team`, and `lifecycle` custom properties.

Supported product types are `service`, `frontend`, `monorepo`, `library`,
`infrastructure`, and `documentation`. Organization infrastructure additionally
uses `governance`, `template`, and `automation`.

## Required baseline

An active software repository must contain:

- a README explaining purpose, owner, setup, tests, deployment, and deeper docs;
- `.github/CODEOWNERS` naming a team with write access;
- at least one GitHub Actions workflow and a stable `ci-required` gate;
- `.gitignore` that excludes local environment and credential files;
- `.editorconfig` and `.gitattributes` that keep cross-platform text and shell
  line endings deterministic;
- source, tests, and documentation in paths appropriate to its repository type;
- canonical `AGENTS.md`, plus `CLAUDE.md` and
  `.github/copilot-instructions.md` pointers to it, when coding agents modify
  the repository.

Service/library repositories normally use `src/`, `tests/`, and `docs/`.
Frontends may use `src/` or `app/`. Monorepos may use `apps/` and `packages/`.
Infrastructure repositories may use `terraform/`, `modules/`, `environments/`,
or `infra/`. Documentation repositories do not need a source or test directory.
Framework-native layouts are valid and ceremonial empty directories are not.

## Documentation

Keep detailed technical documentation under `docs/`. Record durable architecture
decisions as ADRs with context, decision, alternatives, consequences, status,
and date. Update documentation in the same pull request as behavior or
architecture changes.

## CI and security

Private repositories call versioned workflows from
`abc-chain/abc-workflows`; do not copy their implementation into every
repository. GitHub public repositories cannot call workflows from that private
repository and need a reviewed public/local CI design. Use explicit minimal
permissions, never use `secrets: inherit` without a reviewed need, and pin action
steps to full commit SHAs.

Repositories must not track `.env`, credentials, private keys, dependency
caches, or production data. GitHub secret scanning and dependency security
features supplement CI when the repository visibility and plan support them.

## Pull requests and ownership

The intended production baseline is:

- changes to the default branch arrive through pull requests;
- at least one independent approval and sensitive-path Code Owner review;
- `ci-required` passes and conversations are resolved;
- force pushes and branch deletion are blocked;
- bypass is restricted, reviewed, and reserved for recovery.

GitHub Free cannot enforce this baseline for private repositories or create
organization rulesets. The files and custom properties are active now, but full
private-repository enforcement requires GitHub Team or higher and at least two
eligible reviewers.

## Bootstrap and exceptions

Owners create repositories from `abc-repo-template`, apply custom properties,
grant the owning team access, select runtime CI, and verify a successful pull
request before requiring its check context.

An exception must identify the rule, repository and path, accountable owner,
risk and mitigation, approval, and expiry/review date. Exceptions must be narrow
and reviewed through a pull request; they are not permission to commit secrets
or disable organization security controls.
