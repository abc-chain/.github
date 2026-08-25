#!/usr/bin/env bash
set -Eeuo pipefail

required_files=(
  README.md
  AGENTS.md
  .editorconfig
  .gitattributes
  CONTRIBUTING.md
  SECURITY.md
  SUPPORT.md
  PULL_REQUEST_TEMPLATE.md
  REPOSITORY_STANDARD.md
  GOVERNANCE.md
  profile/README.md
  .github/CODEOWNERS
  .github/ISSUE_TEMPLATE/bug.yml
  .github/ISSUE_TEMPLATE/feature.yml
  .github/ISSUE_TEMPLATE/config.yml
)

failure_count=0

for required_file in "${required_files[@]}"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'ERROR: missing organization-default file: %s\n' "$required_file" >&2
    failure_count=$((failure_count + 1))
  fi
done

for workflow_path in workflow-templates/*.yml; do
  properties_path="${workflow_path%.yml}.properties.json"
  if [[ ! -f "$properties_path" ]]; then
    printf 'ERROR: workflow template metadata is missing: %s\n' "$properties_path" >&2
    failure_count=$((failure_count + 1))
  fi
done

mapfile -d '' -t aggregate_workflows < <(
  find .github/workflows workflow-templates -maxdepth 1 -type f \
    \( -name '*.yml' -o -name '*.yaml' \) -print0 | sort -z
)
for workflow_path in "${aggregate_workflows[@]}"; do
  if ! python3 -I - "$workflow_path" <<'PY'
from pathlib import Path
import re
import sys

workflow_path = Path(sys.argv[1])
lines = workflow_path.read_text(encoding="utf-8").splitlines()
workflow_name = workflow_path.as_posix()
runtime_job = {
    ".github/workflows/baseline.yml": None,
    "workflow-templates/abc-baseline.yml": None,
    "workflow-templates/abc-node-ci.yml": "node-ci",
    "workflow-templates/abc-python-ci.yml": "python-ci",
}.get(workflow_name, "unsupported")
if runtime_job == "unsupported":
    raise SystemExit(1)

jobs_starts = [index for index, line in enumerate(lines) if line == "jobs:"]
if len(jobs_starts) != 1:
    raise SystemExit(1)
jobs_start = jobs_starts[0]
job_headers = [
    (index, match.group(1))
    for index, line in enumerate(lines[jobs_start + 1 :], jobs_start + 1)
    if (match := re.fullmatch(r"  ([A-Za-z0-9_-]+):", line)) is not None
]
job_ids = [job_id for _, job_id in job_headers]
expected_job_ids = ["repo-policy", "security"]
if runtime_job is not None:
    expected_job_ids.append(runtime_job)
expected_job_ids.append("ci-required")
if job_ids != expected_job_ids:
    raise SystemExit(1)

if runtime_job is not None:
    runtime_start = next(
        index for index, job_id in job_headers if job_id == runtime_job
    )
    runtime_end = next(
        index for index, _ in job_headers if index > runtime_start
    )
    runtime_block = lines[runtime_start:runtime_end]
    while runtime_block and runtime_block[-1] == "":
        runtime_block.pop()
    expected_runtime_blocks = {
        "node-ci": [
            "  node-ci:",
            "    uses: abc-chain/abc-workflows/.github/workflows/node-ci.yml@v2",
            "    with:",
            '      node_version: "22"',
        ],
        "python-ci": [
            "  python-ci:",
            "    uses: abc-chain/abc-workflows/.github/workflows/python-ci.yml@v2",
            "    with:",
            '      python_version: "3.13"',
        ],
    }
    if runtime_block != expected_runtime_blocks[runtime_job]:
        raise SystemExit(1)

starts = [index for index, line in enumerate(lines) if line == "  ci-required:"]
if len(starts) != 1:
    raise SystemExit(1)

start = starts[0]
end = len(lines)
for index in range(start + 1, len(lines)):
    if re.fullmatch(r"  [A-Za-z0-9_-]+:", lines[index]):
        end = index
        break

block = lines[start:end]
if len(block) < 4:
    raise SystemExit(1)

needs_match = re.fullmatch(
    r"    needs: \[([a-z0-9-]+(?:, [a-z0-9-]+)*)\]",
    block[3],
)
if needs_match is None:
    raise SystemExit(1)
needs = needs_match.group(1).split(", ")
if needs != expected_job_ids[:-1]:
    raise SystemExit(1)

result_variables = ["POLICY_RESULT", "SECURITY_RESULT"]
if len(needs) == 3:
    result_variables.append("RUNTIME_RESULT")

expected = [
    "  ci-required:",
    "    name: ci-required",
    "    if: ${{ always() }}",
    f"    needs: [{', '.join(needs)}]",
    "    runs-on: ubuntu-latest",
    "    timeout-minutes: 5",
    "    steps:",
    "      - name: Verify required jobs",
    "        env:",
]
expected.extend(
    f"          {variable}: ${{{{ needs.{job}.result }}}}"
    for job, variable in zip(needs, result_variables)
)
expected.extend([
    "        run: |",
    "          set -Eeuo pipefail",
])
expected.extend(
    f'          [[ "${variable}" == "success" ]]'
    for variable in result_variables
)
if block != expected:
    raise SystemExit(1)
PY
  then
    printf 'ERROR: ci-required does not match the exact cancellation-safe aggregate in %s.\n' \
      "$workflow_path" >&2
    failure_count=$((failure_count + 1))
  fi
done

while IFS= read -r properties_path; do
  python3 -m json.tool "$properties_path" >/dev/null
done < <(find workflow-templates -maxdepth 1 -type f -name '*.properties.json' | sort)

if ! command -v shellcheck >/dev/null 2>&1; then
  printf 'ERROR: shellcheck is required for governance scripts.\n' >&2
  exit 1
fi
shellcheck --severity=warning scripts/*.sh

if ! command -v actionlint >/dev/null 2>&1; then
  printf 'ERROR: actionlint is required for governance workflow validation.\n' >&2
  exit 1
fi
actionlint .github/workflows/*.yml workflow-templates/*.yml

if python3 -c 'import yaml' >/dev/null 2>&1; then
  while IFS= read -r yaml_path; do
    python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1], encoding="utf-8"))' "$yaml_path"
  done < <(find .github/ISSUE_TEMPLATE -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
elif command -v ruby >/dev/null 2>&1; then
  while IFS= read -r yaml_path; do
    ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0))' "$yaml_path"
  done < <(find .github/ISSUE_TEMPLATE -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
else
  printf 'ERROR: PyYAML or Ruby is required to parse issue forms.\n' >&2
  exit 1
fi

invalid_uses=0
while IFS= read -r uses_target; do
  [[ -z "$uses_target" ]] && continue
  if [[ "$uses_target" == ./* || "$uses_target" =~ @[0-9a-f]{40}$ ||
        "$uses_target" =~ ^abc-chain/abc-workflows/\.github/workflows/[a-z-]+\.yml@v[0-9]+$ ]]; then
    continue
  fi
  printf 'ERROR: unapproved action or reusable-workflow reference: %s\n' "$uses_target" >&2
  invalid_uses=1
done < <(
  find .github/workflows workflow-templates -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 |
    xargs -0 sed -nE 's/^[[:space:]]*(-[[:space:]]+)?uses:[[:space:]]+([^[:space:]#]+).*$/\2/p'
)
(( invalid_uses == 0 )) || exit 1

while IFS= read -r properties_path; do
  icon_name="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["iconName"])' "$properties_path")"
  if [[ "$icon_name" != "octicon "* && ! -f "workflow-templates/$icon_name.svg" ]]; then
    printf 'ERROR: invalid workflow-template iconName in %s: %s\n' "$properties_path" "$icon_name" >&2
    failure_count=$((failure_count + 1))
  fi
done < <(find workflow-templates -maxdepth 1 -type f -name '*.properties.json' | sort)

if ! awk '
  /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
  NF < 2 { bad = 1; next }
  {
    owners = 0
    for (i = 2; i <= NF; i++) {
      if ($i ~ /^#/) break
      owners++
      if ($i !~ /^@[A-Za-z0-9_.-]+(\/[A-Za-z0-9_.-]+)?$/ &&
          $i !~ /^[^[:space:]@]+@[^[:space:]@]+$/) {
        bad = 1
      }
    }
    if (owners == 0) bad = 1
  }
  END { exit bad }
' .github/CODEOWNERS; then
  printf 'ERROR: CODEOWNERS contains an invalid owner.\n' >&2
  failure_count=$((failure_count + 1))
fi

if (( failure_count > 0 )); then
  printf 'Governance validation failed with %d error(s).\n' "$failure_count" >&2
  exit 1
fi

printf 'Governance validation passed.\n'
