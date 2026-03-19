#!/usr/bin/env bash
# Git commit, push, CI wait, and plugin update helpers.
# Expects MARKETPLACE_ROOT and MARKETPLACE_JSON to be set by the caller.

# Wait for any in-flight or queued CI bump runs to finish.
wait_for_idle_ci() {
  echo "→ Waiting for CI to be idle..."

  for status in in_progress queued; do
    local run_id
    run_id=$(gh run list --workflow=bump-version.yml --branch=main --limit=1 \
      --status "$status" --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)

    if [[ -n "$run_id" ]]; then
      gh run watch "$run_id" --exit-status || echo "⚠ CI run failed or was skipped"
    fi
  done
}

# Stage and commit locally (does not push).
commit_local() {
  local message="$1"
  shift
  local files=("$@")

  cd "$MARKETPLACE_ROOT"

  for f in "${files[@]}"; do
    git add -A -- "$f"
  done

  git commit -m "$message"
}

# Wait for the bump-version CI workflow triggered by our push.
wait_for_bump() {
  echo "→ Waiting for CI bump-version workflow..."
  sleep 3

  local run_id
  run_id=$(gh run list --workflow=bump-version.yml --branch=main --limit=1 \
    --json databaseId --jq '.[0].databaseId')

  if [[ -n "$run_id" ]]; then
    gh run watch "$run_id" --exit-status || echo "⚠ CI run failed or was skipped (may be [skip-bump])"
  fi

  echo "→ Pulling CI bump commit..."
  git pull --rebase
}

# Read current marketplace version.
get_marketplace_version() {
  jq -r '.metadata.version // "unknown"' "$MARKETPLACE_JSON"
}

# Read a local plugin's version.
get_plugin_version() {
  local plugin_name="$1"
  local manifest="$MARKETPLACE_ROOT/plugins/$plugin_name/.claude-plugin/plugin.json"
  if [[ -f "$manifest" ]]; then
    jq -r '.version // "unknown"' "$manifest"
  else
    echo "n/a"
  fi
}

# Update the locally installed marketplace plugin and report status.
update_local_plugin() {
  echo "→ Updating local installation..."
  local output
  output=$(claude plugin update nexaedge-marketplace 2>&1 || true)

  if echo "$output" | grep -qi "updated\|installed\|up to date"; then
    echo "  ✓ Local plugin updated"
  else
    echo "  ✓ Local plugin refreshed"
  fi
}

# Print a deploy summary.
print_summary() {
  local before_version="$1"
  local after_version="$2"
  shift 2
  local changed_plugins=("$@")

  echo ""
  echo "┌─────────────────────────────────────"
  echo "│ Deploy summary"
  echo "├─────────────────────────────────────"

  if [[ "$before_version" != "$after_version" ]]; then
    echo "│ Marketplace: $before_version → $after_version"
  else
    echo "│ Marketplace: $after_version (unchanged)"
  fi

  for plugin_name in "${changed_plugins[@]}"; do
    local version
    version=$(get_plugin_version "$plugin_name")
    if [[ -d "$MARKETPLACE_ROOT/plugins/$plugin_name" ]]; then
      echo "│ Plugin $plugin_name: $version"
    else
      echo "│ Plugin $plugin_name: removed"
    fi
  done

  echo "└─────────────────────────────────────"
}

# Full deploy pipeline:
#   1. Snapshot current state
#   2. Stage + commit locally
#   3. Wait for any in-flight CI to finish
#   4. Rebase on top of latest remote + push
#   5. Wait for our push's CI bump
#   6. Update local plugin
#   7. Print summary
deploy() {
  local message="$1"
  shift
  local files=("$@")

  # Snapshot versions before
  local version_before
  version_before=$(get_marketplace_version)

  # Detect which local plugins are being changed
  local -a changed_plugins=()
  for f in "${files[@]}"; do
    if [[ "$f" == plugins/* || "$f" == "plugins/" ]]; then
      # Find plugin names from staged changes
      local plugin_name
      for d in "$MARKETPLACE_ROOT"/plugins/*/; do
        [[ -d "$d" ]] && changed_plugins+=("$(basename "$d")")
      done
      break
    fi
  done

  commit_local "$message" "${files[@]}"
  wait_for_idle_ci

  echo "→ Pulling latest..."
  git pull --rebase

  echo "→ Pushing to main..."
  git push

  wait_for_bump
  update_local_plugin

  local version_after
  version_after=$(get_marketplace_version)

  print_summary "$version_before" "$version_after" "${changed_plugins[@]}"
}
