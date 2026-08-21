# abc organization-default instructions

## Scope

This is a public governance repository. Keep content useful across the entire
`abc-chain` organization and free of confidential information.

- Community defaults live at the repository root.
- Issue forms live in `.github/ISSUE_TEMPLATE/`.
- Starter workflows live in `workflow-templates/` with matching properties JSON.
- The organization profile lives in `profile/README.md`.
- Public-repository self-validation scripts live in `scripts/`.

## Before completing work

- Validate all YAML and JSON files.
- Run `bash scripts/validate.sh` and `bash scripts/security-scan.sh`.
- Confirm workflow actions are pinned to full commit SHAs.
- Confirm starter workflows reference a released `abc-workflows` version.
- Check that issue forms do not depend on labels, assignees, or projects that
  may not exist in every consuming repository.
- Update documentation when an organization-wide contribution rule changes.
- Use a pull request for changes after branch policy is enabled.

Never place secrets, private escalation contacts, customer information, or
internal-only architecture in this public repository.
