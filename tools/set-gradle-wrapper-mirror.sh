#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WRAPPER_FILE="${ROOT}/gradle/wrapper/gradle-wrapper.properties"

if [[ ! -f "${WRAPPER_FILE}" ]]; then
    echo "gradle-wrapper.properties not found: ${WRAPPER_FILE}" >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: bash tools/set-gradle-wrapper-mirror.sh <official|aliyun|huawei>" >&2
    exit 1
fi

PRESET="$1"
CURRENT_URL="$(grep '^distributionUrl=' "${WRAPPER_FILE}" | cut -d= -f2-)"
CURRENT_URL="${CURRENT_URL//\\:/\:}"
VERSION="$(printf '%s' "${CURRENT_URL}" | sed -E 's#.*gradle-([0-9][0-9A-Za-z.\-]*)-bin\.zip#\1#')"

if [[ -z "${VERSION}" || "${VERSION}" == "${CURRENT_URL}" ]]; then
    echo "Failed to detect Gradle version from distributionUrl: ${CURRENT_URL}" >&2
    exit 1
fi

case "${PRESET}" in
    official)
        TARGET_URL="https://services.gradle.org/distributions/gradle-${VERSION}-bin.zip"
        ;;
    aliyun)
        TARGET_URL="https://mirrors.aliyun.com/github/releases/gradle/gradle-distributions/v${VERSION}/gradle-${VERSION}-bin.zip"
        ;;
    huawei)
        TARGET_URL="https://repo.huaweicloud.com/gradle/gradle-${VERSION}-bin.zip"
        ;;
    *)
        echo "Unknown preset: ${PRESET}" >&2
        echo "Supported presets: official, aliyun, huawei" >&2
        exit 1
        ;;
esac

ESCAPED_URL="${TARGET_URL//:/\\:}"
python3 - "$WRAPPER_FILE" "$ESCAPED_URL" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
target_url = sys.argv[2]
lines = path.read_text(encoding="utf-8").splitlines()
updated = []
replaced = False
for line in lines:
    if line.startswith("distributionUrl="):
        updated.append(f"distributionUrl={target_url}")
        replaced = True
    else:
        updated.append(line)

if not replaced:
    raise SystemExit("distributionUrl line not found")

path.write_text("\n".join(updated) + "\n", encoding="utf-8")
PY

printf 'Updated Gradle wrapper mirror to %s\n' "${PRESET}"
printf 'distributionUrl=%s\n' "${ESCAPED_URL}"
