#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_TOML="$ROOT/project.toml"
BACKUP="$(mktemp)"
HARNESS_DIR="$(mktemp -d)"

cp "$PROJECT_TOML" "$BACKUP"

cleanup() {
  cp "$BACKUP" "$PROJECT_TOML"
  rm -f "$BACKUP"
  rm -rf "$HARNESS_DIR"
  rm -rf "$ROOT/native-libs/verify_missing"
  rm -rf "$ROOT/native-libs/verify_present"
  remove_verify_sources
}

remove_verify_sources() {
  rm -f "$ROOT/src/main/java/org/pickaid/templateverify/JavaCallsKotlin.java"
  rm -f "$ROOT/src/main/kotlin/org/pickaid/templateverify/KotlinSmoke.kt"
  rmdir "$ROOT/src/main/java/org/pickaid/templateverify" 2>/dev/null || true
  rmdir -p "$ROOT/src/main/kotlin/org/pickaid/templateverify" 2>/dev/null || true
  rmdir "$ROOT/native-libs" 2>/dev/null || true
}
trap cleanup EXIT

run_gradle_success() {
  local label="$1"
  shift
  echo "[verify] expecting success: $label"
  (cd "$ROOT" && bash ./gradlew "$@" >/tmp/pickaid-template-verify-success.log 2>&1)
}

run_gradle_failure() {
  local label="$1"
  local expected="$2"
  shift 2
  echo "[verify] expecting failure: $label"
  if (cd "$ROOT" && bash ./gradlew "$@" >/tmp/pickaid-template-verify-failure.log 2>&1); then
    echo "Expected Gradle to fail for: $label" >&2
    cat /tmp/pickaid-template-verify-failure.log >&2
    exit 1
  fi
  if ! grep -F "$expected" /tmp/pickaid-template-verify-failure.log >/dev/null; then
    echo "Expected failure output to contain: $expected" >&2
    cat /tmp/pickaid-template-verify-failure.log >&2
    exit 1
  fi
}

append_block() {
  cat >> "$PROJECT_TOML"
}

write_mixed_sources() {
  mkdir -p "$ROOT/src/main/java/org/pickaid/templateverify"
  mkdir -p "$ROOT/src/main/kotlin/org/pickaid/templateverify"
  cat > "$ROOT/src/main/kotlin/org/pickaid/templateverify/KotlinSmoke.kt" <<'KOTLIN'
package org.pickaid.templateverify

object KotlinSmoke {
    @JvmStatic
    fun message(): String = "kotlin smoke"
}
KOTLIN
  cat > "$ROOT/src/main/java/org/pickaid/templateverify/JavaCallsKotlin.java" <<'JAVA'
package org.pickaid.templateverify;

public final class JavaCallsKotlin {
    private JavaCallsKotlin() {
    }

    public static String message() {
        return KotlinSmoke.message();
    }
}
JAVA
}

toml_mod_string() {
  local key="$1"
  awk -v key="$key" '
    /^\[mod\]$/ { in_mod = 1; next }
    /^\[[^]]+\]$/ { in_mod = 0 }
    in_mod {
      pattern = "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*\""
      if ($0 ~ pattern) {
        value = $0
        sub(/^[^"]*"/, "", value)
        sub(/".*$/, "", value)
        print value
        exit
      }
    }
  ' "$PROJECT_TOML"
}

detect_native_platform() {
  local os arch os_part arch_part
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
  case "$os" in
    darwin) os_part="macos" ;;
    linux) os_part="linux" ;;
    msys*|mingw*|cygwin*) os_part="windows" ;;
    *) echo "Unsupported native verification OS: $os" >&2; return 1 ;;
  esac
  case "$arch" in
    x86_64|amd64) arch_part="x86_64" ;;
    arm64|aarch64) arch_part="aarch64" ;;
    *) echo "Unsupported native verification arch: $arch" >&2; return 1 ;;
  esac
  printf '%s-%s\n' "$os_part" "$arch_part"
}

native_file_name() {
  local load_name="$1"
  local platform="$2"
  case "$platform" in
    windows-*) printf '%s.dll\n' "$load_name" ;;
    linux-*) printf 'lib%s.so\n' "$load_name" ;;
    macos-*) printf 'lib%s.dylib\n' "$load_name" ;;
    *) echo "Unsupported native verification platform: $platform" >&2; return 1 ;;
  esac
}

find_loadable_native_library() {
  local java_home candidate
  java_home="$(java -XshowSettings:properties -version 2>&1 | awk -F= '/java.home =/ { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit }')"
  for candidate in \
    "$java_home/lib/libjli.dylib" \
    "$java_home/../MacOS/libjli.dylib" \
    "$java_home/lib/libjli.so" \
    "$java_home/bin/jli.dll" \
    "/usr/lib/libSystem.B.dylib"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo "Could not find a loadable native library for verification" >&2
  return 1
}

prepare_native_present() {
  native_platform="$(detect_native_platform)"
  native_load_name="pickaid_verify_present"
  native_file="$(native_file_name "$native_load_name" "$native_platform")"
  native_source="$(find_loadable_native_library)"
  mkdir -p "$ROOT/native-libs/verify_present/$native_platform"
  cp "$native_source" "$ROOT/native-libs/verify_present/$native_platform/$native_file"
}

append_native_present_block() {
  append_block <<TOML

[native_libraries.verify_present]
load_name = "pickaid_verify_present"
loader = "jni"
required = true
platforms = ["$native_platform"]
TOML
}

run_native_load_harness() {
  native_package="$(printf '%s.%s.runtime' "$(toml_mod_string group)" "$(toml_mod_string mod_id)" | tr '-' '_')"
  cat > "$HARNESS_DIR/NativeLoadHarness.java" <<JAVA
public final class NativeLoadHarness {
    public static void main(String[] args) {
        java.nio.file.Path extracted = ${native_package}.NativeLibraries.load("verify_present");
        if (!java.nio.file.Files.isRegularFile(extracted)) {
            throw new IllegalStateException("Native library was not extracted: " + extracted);
        }
    }
}
JAVA
  javac -cp "$ROOT/build/classes/java/main:$ROOT/build/resources/main" "$HARNESS_DIR/NativeLoadHarness.java"
  java -cp "$HARNESS_DIR:$ROOT/build/classes/java/main:$ROOT/build/resources/main" NativeLoadHarness
}

require_readme_text() {
  local file="$1"
  local text="$2"
  if ! grep -F "$text" "$file" >/dev/null; then
    echo "README is missing usage section text in ${file#$ROOT/}: $text" >&2
    exit 1
  fi
}

remove_top_level_table() {
  local table="$1"
  local temp="$PROJECT_TOML.tmp"
  awk -v table="$table" '
    /^\[[^].]+\]$/ {
      skip = ($0 == "[" table "]")
      if (!skip) print
      next
    }
    !skip { print }
  ' "$PROJECT_TOML" > "$temp"
  mv "$temp" "$PROJECT_TOML"
}

if ! grep -F '2001.6.5-build.16' "$ROOT/project.toml" "$ROOT/README.MD" "$ROOT/README_EN.md" "$ROOT/gradle/template-defaults.toml" >/dev/null; then
  echo "Forge 1.20.1 KubeJS examples/defaults must include 2001.6.5-build.16" >&2
  exit 1
fi

for combo in "Java only" "Kotlin only" "Java + Kotlin" "Java + native" "Java + Kotlin + native"; do
  require_readme_text "$ROOT/README.MD" "$combo"
  require_readme_text "$ROOT/README_EN.md" "$combo"
done
for native_example in "Java_com_example_physicsmod_physics_PhysicsNative_add" "Native.load" "net.java.dev.jna:jna:5.14.0" "clang -shared -fPIC"; do
  require_readme_text "$ROOT/README.MD" "$native_example"
  require_readme_text "$ROOT/README_EN.md" "$native_example"
done

run_gradle_success "java-only default" classes --quiet

cp "$BACKUP" "$PROJECT_TOML"
remove_top_level_table "languages"
write_mixed_sources
append_block <<'TOML'

[languages]
kotlin = true
TOML
run_gradle_success "java+kotlin mixed source" classes --quiet
remove_verify_sources

cp "$BACKUP" "$PROJECT_TOML"
remove_top_level_table "languages"
append_block <<'TOML'

[languages]
kotlin = false
scala = true
TOML
run_gradle_failure "unknown language key" "Unknown languages key" help --quiet

cp "$BACKUP" "$PROJECT_TOML"
prepare_native_present
append_native_present_block
run_gradle_success "native actual load smoke" classes --quiet
run_native_load_harness

cp "$BACKUP" "$PROJECT_TOML"
remove_top_level_table "languages"
write_mixed_sources
prepare_native_present
append_block <<'TOML'

[languages]
kotlin = true
TOML
append_native_present_block
run_gradle_success "java+kotlin+native combined smoke" classes --quiet
run_native_load_harness
remove_verify_sources

cp "$BACKUP" "$PROJECT_TOML"
append_block <<'TOML'

[native_libraries.verify_missing]
load_name = "pickaid_verify_missing"
loader = "jni"
platforms = ["linux-x86_64"]
required = true
TOML
run_gradle_failure "missing native binary" "Missing native library file" help --quiet

echo "[verify] template language/native checks passed"
