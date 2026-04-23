#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-failures.XXXXXX)"
SOURCE_HOME="/Users/gedwen"
trap 'rm -rf "${TMP_ROOT}"' EXIT

export HOME="${TMP_ROOT}/home"
export GRADLE_USER_HOME="${SOURCE_HOME}/.gradle"
mkdir -p "${HOME}"

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

missing_repo="$(copy_repo missing-project)"
rm -f "${missing_repo}/project.toml"
expect_failure "${missing_repo}" "project.toml is required" "${TMP_ROOT}/missing.log"

legacy_template_repo="$(copy_repo legacy-template)"
cat > "${legacy_template_repo}/template.toml" <<'EOF'
schema_version = 1
template_version = "1.20.1-template-1.0.0"
EOF
expect_failure "${legacy_template_repo}" "template.toml is no longer supported; migrate to project.toml" "${TMP_ROOT}/legacy-template.log"

legacy_repo="$(copy_repo legacy-buildtxt)"
cat > "${legacy_repo}/build.txt" <<'EOF'
mod_id=legacy
EOF
expect_failure "${legacy_repo}" "build.txt is no longer supported; migrate to project.toml" "${TMP_ROOT}/legacy.log"

legacy_kubejs_repo="$(copy_repo legacy-kubejs-feature)"
cat > "${legacy_kubejs_repo}/project.toml" <<'EOF'
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
kubejs = true

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${legacy_kubejs_repo}" "Unknown feature key: kubejs" "${TMP_ROOT}/legacy-kubejs.log"

unknown_repo="$(copy_repo unknown-feature)"
cat > "${unknown_repo}/project.toml" <<'EOF'
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
cat > "${override_repo}/project.toml" <<'EOF'
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
cat > "${format_repo}/project.toml" <<'EOF'
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

repository_repo="$(copy_repo invalid-repository)"
cat > "${repository_repo}/project.toml" <<'EOF'
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

[repositories]
latvian = 12

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${repository_repo}" "Repository latvian must be a string URL or inline table" "${TMP_ROOT}/repository.log"

bucket_repo="$(copy_repo invalid-dependency-bucket)"
cat > "${bucket_repo}/project.toml" <<'EOF'
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

[dependencies.dev_only]
helper = "com.example:helper:1.0.0"

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${bucket_repo}" "Unknown dependency bucket: dev_only" "${TMP_ROOT}/bucket.log"

unknown_dev_pack_repo="$(copy_repo unknown-dev-pack)"
cat > "${unknown_dev_pack_repo}/project.toml" <<'EOF'
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

[dev_packs]
unknown_pack = true

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${unknown_dev_pack_repo}" "Unknown dev pack: unknown_pack" "${TMP_ROOT}/unknown-dev-pack.log"

invalid_dev_pack_repo="$(copy_repo invalid-dev-pack-value)"
cat > "${invalid_dev_pack_repo}/project.toml" <<'EOF'
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

[dev_packs]
combat = "yes"

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${invalid_dev_pack_repo}" "dev_packs.combat must be a boolean" "${TMP_ROOT}/invalid-dev-pack.log"

jarjar_repo="$(copy_repo missing-jarjar-range)"
cat > "${jarjar_repo}/project.toml" <<'EOF'
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

[dependencies.jarjar]
helper = { notation = "com.example:helper:1.0.0" }

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "example"
EOF
expect_failure "${jarjar_repo}" "Dependency jarjar.helper must define range" "${TMP_ROOT}/jarjar.log"
