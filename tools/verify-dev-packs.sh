#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-dev-packs.XXXXXX)"
SOURCE_HOME="/Users/gedwen"
trap 'rm -rf "${TMP_ROOT}"' EXIT

export HOME="${TMP_ROOT}/home"
export GRADLE_USER_HOME="${SOURCE_HOME}/.gradle"
mkdir -p "${HOME}"

cp -R "${ROOT}" "${TMP_ROOT}/repo"
rm -rf "${TMP_ROOT}/repo/.gradle" "${TMP_ROOT}/repo/build" "${TMP_ROOT}/repo/.git"

cat > "${TMP_ROOT}/repo/project.toml" <<'EOF'
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
curios = false
geckolib = false
player_animator = false
mixin_extras = true

[dev_packs]
basic = true
appleskin = true
combat = true
curios = true
spell = true
kubejs = true

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF

cd "${TMP_ROOT}/repo"
bash ./gradlew dependencies --configuration runtimeClasspath --no-daemon > "${TMP_ROOT}/runtimeClasspath.log" 2>&1
rg "Enabled dev packs: basic, appleskin, combat, curios, spell, kubejs" "${TMP_ROOT}/runtimeClasspath.log"
rg "jei-1.20.1-forge" "${TMP_ROOT}/runtimeClasspath.log"
rg "jade-324717" "${TMP_ROOT}/runtimeClasspath.log"
rg "attributefix-280510" "${TMP_ROOT}/runtimeClasspath.log"
rg "appleskin-248787" "${TMP_ROOT}/runtimeClasspath.log"
rg "curios-forge" "${TMP_ROOT}/runtimeClasspath.log"
rg "irons_spellbooks" "${TMP_ROOT}/runtimeClasspath.log"
rg "architectury-forge" "${TMP_ROOT}/runtimeClasspath.log"
rg "rhino-forge" "${TMP_ROOT}/runtimeClasspath.log"
rg "kubejs-forge" "${TMP_ROOT}/runtimeClasspath.log"
