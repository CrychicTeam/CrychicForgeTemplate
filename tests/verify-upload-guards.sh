#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_TOML="$ROOT/project.toml"
BACKUP="$(mktemp)"

cp "$PROJECT_TOML" "$BACKUP"
cleanup() {
  cp "$BACKUP" "$PROJECT_TOML"
  rm -f "$BACKUP"
}
trap cleanup EXIT

run_gradle_success() {
  local label="$1"
  shift
  echo "[verify] expecting success: $label"
  (cd "$ROOT" && ./gradlew "$@" >/tmp/pickaid-template-upload-success.log 2>&1)
}

run_gradle_failure() {
  local label="$1"
  local expected="$2"
  shift 2
  echo "[verify] expecting failure: $label"
  if (cd "$ROOT" && ./gradlew "$@" >/tmp/pickaid-template-upload-failure.log 2>&1); then
    echo "Expected Gradle to fail for: $label" >&2
    cat /tmp/pickaid-template-upload-failure.log >&2
    exit 1
  fi
  if ! grep -F "$expected" /tmp/pickaid-template-upload-failure.log >/dev/null; then
    echo "Expected failure output to contain: $expected" >&2
    cat /tmp/pickaid-template-upload-failure.log >&2
    exit 1
  fi
}

replace_table_value() {
  local table="$1"
  local key="$2"
  local replacement="$3"
  local temp="$PROJECT_TOML.tmp"
  awk -v table="[$table]" -v key="$key" -v replacement="$replacement" '
    $0 ~ /^\[[^]]+\]$/ { in_table = ($0 == table) }
    in_table && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
      print replacement
      next
    }
    { print }
  ' "$PROJECT_TOML" > "$temp"
  mv "$temp" "$PROJECT_TOML"
}

require_text() {
  local file="$1"
  local text="$2"
  if ! grep -F "$text" "$file" >/dev/null; then
    echo "Expected ${file#$ROOT/} to contain: $text" >&2
    exit 1
  fi
}

require_absent_text() {
  local file="$1"
  local text="$2"
  if grep -F "$text" "$file" >/dev/null; then
    echo "Unexpected text in ${file#$ROOT/}: $text" >&2
    exit 1
  fi
}

for readme in "$ROOT/README.MD" "$ROOT/README_EN.md"; do
  require_text "$readme" "[publish.mods]"
  require_text "$readme" "publish_maven_before_upload"
  require_text "$readme" "validateUploadConfiguration"
done

run_gradle_failure "no upload target" "At least one upload platform must be configured" validateUploadConfiguration --quiet

replace_table_value "publish.modrinth" "project" 'project = "template-smoke"'
run_gradle_failure "missing Modrinth token" "MODRINTH_TOKEN or publish.modrinth.token or publish.modrinth_token is required" validateUploadConfiguration --quiet
MODRINTH_TOKEN=template-token run_gradle_success "Modrinth target with env token validates" validateUploadConfiguration --quiet
MODRINTH_TOKEN=template-token run_gradle_success "upload task graph resolves without Maven publishing" buildAndUploadMod --dry-run
require_absent_text /tmp/pickaid-template-upload-success.log ":publish SKIPPED"
require_absent_text /tmp/pickaid-template-upload-success.log "publishMavenJavaPublication"

MODRINTH_TOKEN=template-token run_gradle_success "upload task listing" tasks --group upload --quiet
require_text /tmp/pickaid-template-upload-success.log "uploadCurseForge"
require_absent_text /tmp/pickaid-template-upload-success.log "curseforge0"

echo "[verify] upload configuration checks passed"
