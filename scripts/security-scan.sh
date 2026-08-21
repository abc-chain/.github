#!/usr/bin/env bash
set -Eeuo pipefail

finding_count=0

report_matches() {
  local label="$1"
  local expression="$2"
  local grep_output
  local grep_status=0
  local matched_path
  grep_output="$(mktemp)"
  if git grep -a -z -l -E -e "$expression" -- . >"$grep_output"; then
    grep_status=0
  else
    grep_status=$?
  fi
  if (( grep_status > 1 )); then
    rm -f -- "$grep_output"
    printf 'ERROR: git grep exited %d while scanning for %s.\n' "$grep_status" "$label" >&2
    exit 1
  fi
  while IFS= read -r -d '' matched_path; do
    [[ -z "$matched_path" ]] && continue
    printf 'ERROR: potential %s in %q; content suppressed.\n' "$label" "$matched_path" >&2
    finding_count=$((finding_count + 1))
  done <"$grep_output"
  rm -f -- "$grep_output"
}

report_matches "private key" '-----BEGIN (RSA |DSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----'
report_matches "AWS access key" '(AKIA|ASIA)[0-9A-Z]{16}'
report_matches "GitHub token" 'gh[pousr]_[A-Za-z0-9]{36,255}'
report_matches "GitHub fine-grained token" 'github_pat_[A-Za-z0-9_]{82,255}'

while IFS= read -r -d '' tracked_path; do
  case "${tracked_path##*/}" in
    .env|credentials.json|id_rsa|id_dsa|id_ecdsa|id_ed25519|*.p12|*.pfx)
      printf 'ERROR: forbidden tracked credential path: %q\n' "$tracked_path" >&2
      finding_count=$((finding_count + 1))
      ;;
  esac
done < <(git ls-files -z)

if (( finding_count > 0 )); then
  printf 'Public-content security scan failed with %d finding(s).\n' "$finding_count" >&2
  exit 1
fi

printf 'Public-content security scan passed.\n'
