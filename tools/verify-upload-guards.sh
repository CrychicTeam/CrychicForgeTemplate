#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-upload-guards.XXXXXX)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

cp -R "${ROOT}" "${TMP_ROOT}/repo"
rm -rf "${TMP_ROOT}/repo/.gradle" "${TMP_ROOT}/repo/build" "${TMP_ROOT}/repo/.git"

cat > "${TMP_ROOT}/repo/template.toml" <<'EOF'
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
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF

if (cd "${TMP_ROOT}/repo" && bash ./gradlew build --no-daemon > "${TMP_ROOT}/build.log" 2>&1); then
    rg "BUILD SUCCESSFUL" "${TMP_ROOT}/build.log"
else
    cat "${TMP_ROOT}/build.log" >&2
    exit 1
fi

if (cd "${TMP_ROOT}/repo" && bash ./gradlew buildAndUploadMod --no-daemon > "${TMP_ROOT}/upload.log" 2>&1); then
    echo "Expected buildAndUploadMod to fail without any configured platform" >&2
    exit 1
fi

rg "At least one upload platform must be configured" "${TMP_ROOT}/upload.log"
