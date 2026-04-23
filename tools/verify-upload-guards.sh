#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-upload-guards.XXXXXX)"
SOURCE_HOME="/Users/gedwen"
trap 'rm -rf "${TMP_ROOT}"' EXIT

export HOME="${TMP_ROOT}/home"
export GRADLE_USER_HOME="${SOURCE_HOME}/.gradle"
mkdir -p "${HOME}"

cp -R "${ROOT}" "${TMP_ROOT}/repo"
rm -rf "${TMP_ROOT}/repo/.gradle" "${TMP_ROOT}/repo/build" "${TMP_ROOT}/repo/.git"

write_project_config() {
    local modrinth_project="$1"
    local curseforge_project="$2"
    local modrinth_token="${3:-}"
    local curseforge_token="${4:-}"
    local maven_user="${5:-}"
    local maven_password="${6:-}"

    cat > "${TMP_ROOT}/repo/project.toml" <<EOF
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

[publish]
maven_url = ""
$( [ -n "${maven_user}" ] && printf 'maven_user = "%s"\n' "${maven_user}" )
$( [ -n "${maven_password}" ] && printf 'maven_password = "%s"\n' "${maven_password}" )
$( [ -n "${modrinth_token}" ] && printf 'modrinth_token = "%s"\n' "${modrinth_token}" )
$( [ -n "${curseforge_token}" ] && printf 'curseforge_token = "%s"\n' "${curseforge_token}" )
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

write_project_config "" 0

if (cd "${TMP_ROOT}/repo" && bash ./gradlew build --no-daemon > "${TMP_ROOT}/build.log" 2>&1); then
    rg "BUILD SUCCESSFUL" "${TMP_ROOT}/build.log"
else
    cat "${TMP_ROOT}/build.log" >&2
    exit 1
fi

expect_upload_failure "${TMP_ROOT}/upload-no-platform.log" "At least one upload platform must be configured"

write_project_config "example-project" 0
expect_upload_failure "${TMP_ROOT}/upload-modrinth.log" "MODRINTH_TOKEN or publish.modrinth_token is required when modrinth_project is configured"

write_project_config "" 123456
expect_upload_failure "${TMP_ROOT}/upload-curseforge.log" "CURSEFORGE_TOKEN or publish.curseforge_token is required when curseforge_project is configured"

write_project_config "example-project" 0 "toml-modrinth-token"
if (cd "${TMP_ROOT}/repo" && bash ./gradlew validateUploadConfiguration --no-daemon > "${TMP_ROOT}/toml-modrinth.log" 2>&1); then
    rg "BUILD SUCCESSFUL" "${TMP_ROOT}/toml-modrinth.log"
else
    cat "${TMP_ROOT}/toml-modrinth.log" >&2
    exit 1
fi

write_project_config "" 123456 "" "toml-curseforge-token"
if (cd "${TMP_ROOT}/repo" && bash ./gradlew validateUploadConfiguration --no-daemon > "${TMP_ROOT}/toml-curseforge.log" 2>&1); then
    rg "BUILD SUCCESSFUL" "${TMP_ROOT}/toml-curseforge.log"
else
    cat "${TMP_ROOT}/toml-curseforge.log" >&2
    exit 1
fi
