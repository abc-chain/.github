# Contributing at abc

## Before starting

1. Confirm the repository's `README.md`, `AGENTS.md`, and local contribution
   guidance. Repository-specific instructions take precedence over this default.
2. Open or reference an issue for changes that need product or architectural
   agreement.
3. Work on a focused branch such as `feature/...`, `fix/...`, or `chore/...`.

## Make the change

- Keep source, tests, documentation, scripts, and infrastructure in the
  repository's established locations.
- Add or update tests for behavior changes.
- Update documentation and an ADR when an architectural decision changes.
- Never commit `.env` files, credentials, private keys, access tokens, or
  production data.
- Avoid unrelated formatting or refactoring in the same pull request.

## Before requesting review

- Run the repository's documented lint, test, security, and policy checks.
- Complete the pull request template accurately.
- Keep the pull request small enough to review and explain any intentional
  exception to repository policy.
- Resolve review conversations rather than silently dismissing them.

The default branch is intended to change through reviewed pull requests once
the repository's GitHub plan and protection policy support enforcement.
