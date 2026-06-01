#!/usr/bin/env bash
#
# Flip `main` branch protection to the STRICT (team) profile.
# Run this ONCE you have a second collaborator who can review PRs.
#
# Difference from the current solo-friendly profile:
#   - required_approving_review_count: 0 -> 1   (a human must approve)
#   - require_code_owner_reviews:    false -> true (CODEOWNERS review required)
#   - enforce_admins:                false -> true (rules also bind admins/owner)
#
# WARNING: after running this you CANNOT merge your own PRs without another
# collaborator's approval. Do not run it while you are the only collaborator.
#
# Usage:  gh auth login   # as a repo admin
#         bash scripts/protect-main-strict.sh
set -euo pipefail

REPO="${REPO:-drdeebtech/Hesn}"

read -r -p "Apply STRICT protection to ${REPO}:main? You need another reviewer. [y/N] " ans
[[ "${ans:-}" == "y" || "${ans:-}" == "Y" ]] || { echo "Aborted."; exit 1; }

gh api -X PUT "repos/${REPO}/branches/main/protection" \
  -H "Accept: application/vnd.github+json" \
  --input - <<'JSON'
{
  "required_status_checks": { "strict": true, "contexts": ["analyze & test"] },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true,
  "block_creations": false
}
JSON

echo "Strict protection applied to ${REPO}:main."
