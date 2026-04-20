#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-failures.XXXXXX)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

copy_repo() {
    local name="$1"
    local target="${TMP_ROOT}/${name}"
    cp -R "${ROOT}" "${target}"
    rm -rf "${target}/.gradle" "${target}/build" "${target}/.git"
    printf '%s\n' "${target}"
}

expect_failure() {
    local repo="$1"
    local needle="$2"
    local log_file="$3"
    if (cd "${repo}" && bash ./gradlew help --no-daemon > "${log_file}" 2>&1); then
        echo "Expected failure in ${repo}" >&2
        exit 1
    fi
    rg "${needle}" "${log_file}"
}

missing_repo="$(copy_repo missing-template)"
rm -f "${missing_repo}/template.toml"
expect_failure "${missing_repo}" "template.toml is required" "${TMP_ROOT}/missing.log"

legacy_repo="$(copy_repo legacy-buildtxt)"
cat > "${legacy_repo}/build.txt" <<'EOF'
mod_id=legacy
EOF
expect_failure "${legacy_repo}" "build.txt is no longer supported" "${TMP_ROOT}/legacy.log"

unknown_repo="$(copy_repo unknown-feature)"
cat > "${unknown_repo}/template.toml" <<'EOF'
schema_version = 1
template_version = "1.20.1-template-1.0.0"

[mod]
mod_id = "example"
mod_name = "Example"
version = "0.0.1"
group = "com.example"
authors = ["Example"]
license = "MIT"
description = "Example"

[features]
jei = false
unknown_feature = true

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${unknown_repo}" "Unknown feature key: unknown_feature" "${TMP_ROOT}/unknown.log"

override_repo="$(copy_repo disabled-override)"
cat > "${override_repo}/template.toml" <<'EOF'
schema_version = 1
template_version = "1.20.1-template-1.0.0"

[mod]
mod_id = "example"
mod_name = "Example"
version = "0.0.1"
group = "com.example"
authors = ["Example"]
license = "MIT"
description = "Example"

[features]
player_animator = false

[overrides]
player_animator_version = "1.0.2+1.20"

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${override_repo}" "Override player_animator_version requires enabled feature player_animator" "${TMP_ROOT}/override.log"

format_repo="$(copy_repo invalid-format)"
cat > "${format_repo}/template.toml" <<'EOF'
schema_version = 1
template_version = "1.20.1-template-1.0.0"

[mod]
mod_id = "example"
mod_name = "Example"
version = "0.0.1"
group = "com.example"
authors = ["Example"]
license = "MIT"
description = "Example"

[features]
jei = false

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
jar_format = "{archive_name}-{bad_token}"
EOF
expect_failure "${format_repo}" "Unsupported jar_format token: bad_token" "${TMP_ROOT}/format.log"
