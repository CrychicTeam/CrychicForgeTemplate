#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
GROUP_PATH="com/mihono/pickaid/example/0.0.1"
RUN_ROOT="$(mktemp -d /tmp/pickaid-template-publication.XXXXXX)"
SOURCE_HOME="/Users/gedwen"

cleanup() {
    rm -rf "${RUN_ROOT}"
}
trap cleanup EXIT

export HOME="${RUN_ROOT}/home"
export GRADLE_USER_HOME="${SOURCE_HOME}/.gradle"

mkdir -p "${HOME}"
LOCAL_M2="${HOME}/.m2/repository"
ARTIFACT_DIR="${LOCAL_M2}/${GROUP_PATH}"

cd "${ROOT}"
rm -rf "${ARTIFACT_DIR}"
bash ./gradlew publishToMavenLocal --no-daemon "-Duser.home=${HOME}"

test -f "${ARTIFACT_DIR}/example-0.0.1.jar"
test -f "${ARTIFACT_DIR}/example-0.0.1-sources.jar"
test -f "${ARTIFACT_DIR}/example-0.0.1-javadoc.jar"
test -f "${ARTIFACT_DIR}/example-0.0.1-runtime.jar"
test ! -f "${ARTIFACT_DIR}/example-0.0.1.module"

jar tf "${ARTIFACT_DIR}/example-0.0.1-javadoc.jar" | rg "org/pickaid/modid/Example.html"
jar tf "${ARTIFACT_DIR}/example-0.0.1-sources.jar" | rg "org/pickaid/modid/Example.java"
rg "<artifactId>Registrate</artifactId>" "${ARTIFACT_DIR}/example-0.0.1.pom"
if rg "_mapped_" "${ARTIFACT_DIR}/example-0.0.1.pom"; then
    echo "Published POM must not leak mapped dependency versions" >&2
    exit 1
fi
