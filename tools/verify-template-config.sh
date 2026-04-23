#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"

cd "${ROOT}"
test -f project.toml
test ! -f template.toml
test ! -f build.txt
bash ./gradlew help --no-daemon > /tmp/pickaid-template-help.log 2>&1
rg "BUILD SUCCESSFUL" /tmp/pickaid-template-help.log
bash ./gradlew properties --no-daemon > /tmp/pickaid-template-properties.log 2>&1
rg "^version: 0.0.1$" /tmp/pickaid-template-properties.log
rg "^group: com.mihono.pickaid$" /tmp/pickaid-template-properties.log
