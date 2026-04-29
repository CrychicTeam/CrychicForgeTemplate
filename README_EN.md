<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate - Forge 1.19.2 Mod Template

English Version | [中文版](README.MD)

`PickAIDForgeTemplate-1.19.2` is only for `Forge 1.19.2`. This branch is curated for the real 1.19.2 ecosystem: built-in versions, CurseMaven file ids, local helper packs, and publishing tasks all target this branch.

Goals:

- New projects mostly edit `project.toml`
- Common ecosystem dependencies do not need hard-coded `build.gradle` edits
- Java is enabled by default, Kotlin is opt-in
- Rust/C/C++ native libraries are supported as prebuilt JNI/JNA binaries only; this template does not compile native source code
- Local helper packs, publishing, and archive naming all use one configuration model

## Branch Rules

Versions are managed by branches, not profiles.

- This branch only targets `Forge 1.19.2`
- It does not accept `project.toml [platform]`
- It does not accept `-PtemplateProfile=...`
- `build.txt` and `template.toml` are deprecated

## What This Branch Includes

- `Forge 1.19.2` with `ModDevGradle LegacyForge`
- Single-entry configuration through `project.toml`
- Built-in feature switches: `jei`, `curios`, `geckolib`, `player_animator`, `mixin_extras`
- Built-in local helper packs: `basic`, `appleskin`, `combat`, `curios`, `spell`, `kubejs`
- Java plus optional Kotlin mixed compilation
- Prebuilt JNI/JNA native packaging and a generated runtime loading helper
- Maven publication and Modrinth / CurseForge upload tasks
- Shared Mixin and `mods.toml` templates

## Quick Start

### 1. Edit `project.toml`

These are usually the first fields to change:

```toml
schema_version = 1
template_version = "1.19.2-template-1.1.0"

[mod]
mod_id = "yourmod"
mod_name = "Your Mod"
version = "1.0.0"
version_suffix = ""
group = "com.yourname.yourmod"
authors = ["Your Name"]
license = "MIT"
description = "What this mod does."
```

For prereleases or hotfixes:

```toml
version = "1.2.0"
version_suffix = "hotfix.1"
```

The final version becomes `1.2.0-hotfix.1`.

### 2. Replace Example Code

Start with:

1. `src/main/java/org/pickaid/example/Example.java`
2. `src/templates/META-INF/mods.toml`
3. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
4. `src/templates/mixins.json`

If your project does not use Mixins, remove the example Mixin and template entry.

### 3. Run Gradle

```bash
./gradlew help
./gradlew build
```

If these pass, the template is basically wired to your mod identity.

## Common `project.toml` Blocks

### `[mod]`

Primary mod identity:

- `mod_id`
- `mod_name`
- `version`
- `version_suffix`
- `group`
- `authors`
- `license`
- `description`

### `[features]`

Built-in ecosystem switches:

- `jei`
- `curios`
- `geckolib`
- `player_animator`
- `mixin_extras`

### `[languages]`

Java is always enabled. Kotlin is optional; when enabled, sources under `src/main/kotlin` compile together with `src/main/java`:

```toml
[languages]
kotlin = true
```

Recommended priority is Java > Kotlin > native. Use Java for the normal Forge API surface and most dependencies, Kotlin when its syntax or libraries help, and native libraries only for advanced JNI/JNA integrations.

### `[dev_packs]`

These are local development helpers, not your published API surface.

Built-in packs:

- `basic`: JEI + Jade
- `appleskin`: AppleSkin
- `combat`: Target Dummy + AttributeFix + Max Health Fix
- `curios`: Curios runtime
- `spell`: Caelus + Iron's Spellbooks
- `kubejs`: Architectury + Rhino + KubeJS runtime

The `kubejs` pack is curated for real `1.19.2` development and can be used for local script smoke tests.

### `[repositories]` and `[dependencies.*]`

Put extra repositories and dependencies here instead of hard-coding them in `build.gradle`.

Common dependency buckets:

- `api`
- `implementation`
- `compile_only_api`
- `compile_only`
- `runtime_only`
- `annotation_processor`
- `deobf_api`
- `deobf_implementation`
- `deobf_compile_only_api`
- `deobf_compile_only`
- `deobf_runtime_only`
- `jarjar`

`project.toml` already contains commented 1.19.2 examples you can enable and adjust.

### `[native_libraries.*]`

This advanced feature packages already-built JNI/JNA binaries. It does not build Rust/C/C++ source code. Declare one child table per library:

```toml
[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["windows-x86_64", "linux-x86_64", "macos-aarch64"]
required = true
```

The file layout must match the platform names:

```text
native-libs/
  physics/
    windows-x86_64/pickaid_physics.dll
    linux-x86_64/libpickaid_physics.so
    macos-aarch64/libpickaid_physics.dylib
```

At build time, the template packages those files into the jar and generates a `NativeLibraries` Java helper. At runtime, call `load("physics")` from `${group}.${mod_id}.runtime.NativeLibraries`.

#### JNI: Call Native Methods From Java or Kotlin

Given:

```toml
[mod]
mod_id = "physicsmod"
group = "com.example"

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["macos-aarch64", "linux-x86_64", "windows-x86_64"]
required = true
```

The generated helper package is `com.example.physicsmod.runtime.NativeLibraries`. Load the library before declaring native methods:

```java
package com.example.physicsmod.physics;

import com.example.physicsmod.runtime.NativeLibraries;

public final class PhysicsNative {
    static {
        NativeLibraries.load("physics");
    }

    private PhysicsNative() {
    }

    public static native int add(int left, int right);
}
```

Kotlin can call that Java wrapper directly:

```kotlin
val result = PhysicsNative.add(20, 22)
```

The C function name must match the Java package, class, and method:

```c
#include <jni.h>

JNIEXPORT jint JNICALL Java_com_example_physicsmod_physics_PhysicsNative_add(
    JNIEnv *env,
    jclass type,
    jint left,
    jint right
) {
    return left + right;
}
```

Put the compiled output under the template layout. macOS aarch64 example:

```bash
mkdir -p native-libs/physics/macos-aarch64
clang -dynamiclib \
  -I"$JAVA_HOME/include" \
  -I"$JAVA_HOME/include/darwin" \
  physics.c \
  -o native-libs/physics/macos-aarch64/libpickaid_physics.dylib
```

Linux x86_64 example:

```bash
mkdir -p native-libs/physics/linux-x86_64
clang -shared -fPIC \
  -I"$JAVA_HOME/include" \
  -I"$JAVA_HOME/include/linux" \
  physics.c \
  -o native-libs/physics/linux-x86_64/libpickaid_physics.so
```

Windows should output `native-libs/physics/windows-x86_64/pickaid_physics.dll`.

#### JNA: Bind an Existing C ABI Library

If the native library exports plain C functions and you do not want JNI glue code, use JNA. First package JNA:

```toml
[dependencies.jarjar]
jna = { notation = "net.java.dev.jna:jna:5.14.0", range = "[5.14.0,)" }

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jna"
platforms = ["macos-aarch64", "linux-x86_64", "windows-x86_64"]
required = true
```

Java binding example:

```java
package com.example.physicsmod.physics;

import com.example.physicsmod.runtime.NativeLibraries;
import com.sun.jna.Library;
import com.sun.jna.Native;

public interface PhysicsLibrary extends Library {
    PhysicsLibrary INSTANCE = Native.load(
        NativeLibraries.load("physics").toString(),
        PhysicsLibrary.class
    );

    int add(int left, int right);
}
```

Kotlin can call the same JNA binding:

```kotlin
val result = PhysicsLibrary.INSTANCE.add(20, 22)
```

The C library only needs to export a normal function:

```c
int add(int left, int right) {
    return left + right;
}
```

JNI is a better fit for performance-sensitive code or deeper JVM interaction. JNA is better for existing C ABI libraries.

## Usage Combinations

### Java only

Keep the default:

```toml
[languages]
kotlin = false
```

Put code under `src/main/java`.

### Kotlin only

Enable Kotlin and put mod code under `src/main/kotlin`. The Java toolchain remains enabled because Forge, annotation processing, and generated code still use Java infrastructure.

```toml
[languages]
kotlin = true
```

### Java + Kotlin

Enable Kotlin and use both `src/main/java` and `src/main/kotlin`. Java can call Kotlin JVM APIs such as `@JvmStatic` members, and Kotlin can call Java classes directly.

```toml
[languages]
kotlin = true
```

### Java + native

Keep Kotlin off and declare the native library. Java code calls the generated helper:

```toml
[languages]
kotlin = false

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["windows-x86_64", "linux-x86_64", "macos-aarch64"]
required = true
```

```java
NativeLibraries.load("physics");
```

### Java + Kotlin + native

Enable Kotlin and native support together. Java and Kotlin can both call the generated `NativeLibraries` helper:

```toml
[languages]
kotlin = true

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["windows-x86_64", "linux-x86_64", "macos-aarch64"]
required = true
```

```kotlin
NativeLibraries.load("physics")
```

## Local Private Config

`project.local.toml` is ignored by git and is intended for:

- `[run].mc_user`
- Maven credentials
- Modrinth / CurseForge tokens

You can copy it from [`project.local.toml.example`](/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate-1.19.2/project.local.toml.example).

## Publishing

Publishing is configured through `project.toml` / `project.local.toml`.

Recommended split:

1. Repository URLs go in `project.toml`
2. Usernames, passwords, and tokens go in `project.local.toml` or environment variables

Supported environment variables:

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

## Common Commands

```bash
./gradlew help
./gradlew build
./gradlew publishToMavenLocal
./gradlew validateUploadConfiguration
```
