#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-upload-guards.XXXXXX)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

cp -R "${ROOT}" "${TMP_ROOT}/repo"
rm -rf "${TMP_ROOT}/repo/.gradle" "${TMP_ROOT}/repo/build" "${TMP_ROOT}/repo/.git"

write_template() {
    local modrinth_project="$1"
    local curseforge_project="$2"

    cat > "${TMP_ROOT}/repo/template.toml" <<EOF
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
mixin_extras = true
kubejs = true

[publish]
maven_url = ""
curseforge_project = ${curseforge_project}
modrinth_project = "${modrinth_project}"
release_type = "alpha"

[naming]
archive_name = "example"
EOF
}

expect_upload_failure() {
    local log_path="$1"
    local expected_message="$2"

    if (cd "${TMP_ROOT}/repo" && bash ./gradlew buildAndUploadMod --no-daemon > "${log_path}" 2>&1); then
        echo "Expected buildAndUploadMod to fail: ${expected_message}" >&2
        exit 1
    fi

    rg "${expected_message}" "${log_path}"
}

write_template "" 0

if (cd "${TMP_ROOT}/repo" && bash ./gradlew build --no-daemon > "${TMP_ROOT}/build.log" 2>&1); then
    rg "BUILD SUCCESSFUL" "${TMP_ROOT}/build.log"
else
    cat "${TMP_ROOT}/build.log" >&2
    exit 1
fi

expect_upload_failure "${TMP_ROOT}/upload-no-platform.log" "At least one upload platform must be configured"

write_template "example-project" 0
expect_upload_failure "${TMP_ROOT}/upload-modrinth.log" "MODRINTH_TOKEN is required when modrinth_project is configured"

write_template "" 123456
expect_upload_failure "${TMP_ROOT}/upload-curseforge.log" "CURSEFORGE_TOKEN is required when curseforge_project is configured"
