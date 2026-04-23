#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-generic-deps.XXXXXX)"
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

[overrides]
mixin_extras_version = "0.2.0-beta.8"

[repositories]
extra_architectury_source = "https://maven.architectury.dev"
script_stack_source = "https://maven.latvian.dev/releases"

[dependencies.deobf_api]
ui_registration_surface = "com.tterrag.registrate:Registrate:MC1.20-1.3.2"

[dependencies.deobf_compile_only_api]
slot_api_surface = "top.theillusivec4.curios:curios-forge:5.9.1+1.20.1"

[dependencies.deobf_compile_only]
script_entry_bridge = "dev.latvian.mods:kubejs-forge:2001.6.4-build.120"
embedded_js_engine = "dev.latvian.mods:rhino-forge:2001.2.2-build.18"

[dependencies.deobf_implementation]
platform_runtime_bridge = { notation = "dev.architectury:architectury-forge:9.1.12", transitive = false }

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF

cd "${TMP_ROOT}/repo"
bash ./gradlew compileJava --no-daemon > "${TMP_ROOT}/compile.log" 2>&1
rg "BUILD SUCCESSFUL" "${TMP_ROOT}/compile.log"
bash ./gradlew dependencies --configuration compileClasspath --no-daemon > "${TMP_ROOT}/deps.log" 2>&1
rg "Registrate:MC1.20-1.3.2" "${TMP_ROOT}/deps.log"
rg "curios-forge:5.9.1\\+1.20.1" "${TMP_ROOT}/deps.log"
