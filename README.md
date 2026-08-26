# abc organization defaults

This public repository provides community-health files, issue forms, pull
request guidance, workflow starters, and the organization profile for
[`abc-chain`](https://github.com/abc-chain).

GitHub applies supported files here to organization repositories that do not
define their own equivalent. Repository-specific files may override a default
when the project has a documented need.

## Applied by GitHub

- `CONTRIBUTING.md`, `SECURITY.md`, and `SUPPORT.md`
- `PULL_REQUEST_TEMPLATE.md`
- `.github/ISSUE_TEMPLATE/`
- `workflow-templates/`
- `profile/README.md`

## Published governance references

- `REPOSITORY_STANDARD.md` and `GOVERNANCE.md`

This repository is public because GitHub requires a public `.github` repository
for most organization-wide community files. Do not add internal contacts,
credentials, private architecture, or confidential operational details.

The repository validates itself locally because GitHub does not allow a public
caller to invoke workflows from the private `abc-workflows` repository. Starter
workflows that call `abc-workflows` are intended for abc private repositories.
The published starters target the current `v2` compatibility line. Before a
starter update that selects a new major is merged, maintainers must publish its
immutable release and major tag, then prove both tags resolve to the same
reviewed `abc-workflows` commit.
