#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"

cd "${ROOT}"
test -f template.toml
test ! -f build.txt
bash ./gradlew help --no-daemon > /tmp/pickaid-template-help.log 2>&1
rg "BUILD SUCCESSFUL" /tmp/pickaid-template-help.log
