#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
TMP_ROOT="$(mktemp -d /tmp/pickaid-template-wrapper-mirror.XXXXXX)"
SOURCE_HOME="/Users/gedwen"
trap 'rm -rf "${TMP_ROOT}"' EXIT

export HOME="${TMP_ROOT}/home"
export GRADLE_USER_HOME="${SOURCE_HOME}/.gradle"
mkdir -p "${HOME}"

cp -R "${ROOT}" "${TMP_ROOT}/repo"
rm -rf "${TMP_ROOT}/repo/.gradle" "${TMP_ROOT}/repo/build" "${TMP_ROOT}/repo/.git"

cd "${TMP_ROOT}/repo"

bash tools/set-gradle-wrapper-mirror.sh aliyun > "${TMP_ROOT}/aliyun.log"
rg "Updated Gradle wrapper mirror to aliyun" "${TMP_ROOT}/aliyun.log"
rg '^distributionUrl=https\\://mirrors.aliyun.com/github/releases/gradle/gradle-distributions/v8.13/gradle-8.13-bin.zip$' gradle/wrapper/gradle-wrapper.properties

bash tools/set-gradle-wrapper-mirror.sh huawei > "${TMP_ROOT}/huawei.log"
rg "Updated Gradle wrapper mirror to huawei" "${TMP_ROOT}/huawei.log"
rg '^distributionUrl=https\\://repo.huaweicloud.com/gradle/gradle-8.13-bin.zip$' gradle/wrapper/gradle-wrapper.properties

bash tools/set-gradle-wrapper-mirror.sh official > "${TMP_ROOT}/official.log"
rg "Updated Gradle wrapper mirror to official" "${TMP_ROOT}/official.log"
rg '^distributionUrl=https\\://services.gradle.org/distributions/gradle-8.13-bin.zip$' gradle/wrapper/gradle-wrapper.properties
