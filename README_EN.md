<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate — NeoForge 26.1 Mod Template

English | [中文版](README.MD)

`PickAIDForgeTemplate-26.1` is the `Minecraft 26.1.2` / `NeoForge 26.1.x` template line. It uses `project.toml` as the single configuration surface for **mod identity, dependencies, run settings, and publishing**, so new projects do not start with Gradle cleanup work.

## Contents

- [What You Get](#what-you-get)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration Reference](#configuration-reference)
  - [[mod] — mod identity](#mod--mod-identity)
  - [[features] — ecosystem feature switches](#features--ecosystem-feature-switches)
  - [[languages] — Java/Kotlin switches](#languages--javakotlin-switches)
  - [[overrides] — version overrides](#overrides--version-overrides)
  - [[dev_packs] — local helper packs](#dev_packs--local-helper-packs)
  - [[repositories] — extra Maven repositories](#repositories--extra-maven-repositories)
  - [[dependencies.*] / [embedded_projects.*] — extra dependencies and embedded subprojects](#dependencies--embedded_projects--extra-dependencies-and-embedded-subprojects)
  - [[native_libraries.*] — prebuilt native libraries](#native_libraries--prebuilt-native-libraries)
  - [[metadata] — mod display metadata](#metadata--mod-display-metadata)
  - [[mod_relations.*] — mod relation declarations](#mod_relations--mod-relation-declarations)
  - [[publish] — publishing settings](#publish--publishing-settings)
  - [[naming] — artifact naming](#naming--artifact-naming)
- [Project Layout](#project-layout)
- [Publishing Guide](#publishing-guide)
- [Artifacts](#artifacts)
- [How Downstream Mods Depend On It](#how-downstream-mods-depend-on-it)
- [Gradle Mirrors](#gradle-mirrors)
- [Common Commands](#common-commands)
- [FAQ](#faq)

## What You Get

Out of the box this branch already includes:

- A buildable `NeoForge 26.1` project skeleton
- TOML-driven project configuration through `project.toml`
- Curated feature switches for JEI, Curios, and MixinExtras
- Java-first language support with optional Kotlin sources
- Local helper packs for `basic`, `appleskin`, and `curios`
- Maven publication for the main jar, `sources`, and `javadoc`
- Modrinth and CurseForge upload tasks
- TOML-based repository and dependency management for most project needs

> This branch does not use `build.txt`, `template.toml`, `[platform]`, or `-PtemplateProfile=...`.

## Prerequisites

- **JDK 25** or Gradle toolchain auto-download enabled for JDK 25
- A usable Gradle environment through the included wrapper
- Basic Minecraft modding context such as `mod_id`, Mixins, `neoforge.mods.toml`, and Maven dependencies

## Quick Start

### 1. Clone the template

```bash
git clone <repository-url>
cd PickAIDForgeTemplate-26.1
```

### 2. Edit `project.toml`

For a new project, start with these blocks:

```toml
[mod]
mod_id = "yourmod"
mod_name = "Your Mod"
version = "1.0.0"
group = "com.yourname.yourmod"
authors = ["Your Name"]
license = "MIT"
description = "What this mod does."

[naming]
archive_name = "yourmod"
jar_format = "{archive_name}-{mc_version}-{version}"
```

If you need a preview build or hotfix build:

```toml
version = "1.2.0"
version_suffix = "hotfix.1"
```

That renders the final version as `1.2.0-hotfix.1`.

### 3. Replace the placeholders

The first files you usually touch are:

1. `src/main/java/org/pickaid/example/Example.java`
2. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
3. `src/templates/META-INF/neoforge.mods.toml`
4. `src/templates/mixins.json`

If your mod does not use Mixins, remove the sample mixin and `src/templates/mixins.json`.

### 4. Import Gradle and build once

```bash
./gradlew help
./gradlew build
```

This branch is on `ModDevGradle`, so the old `genIntellijRuns` flow is no longer the right workflow. Import the Gradle project and let the IDE sync.

### 5. Optional: create `project.local.toml`

Copy the example file for machine-local settings:

```bash
cp project.local.toml.example project.local.toml
```

Typical local-only values:

- `[run].mc_user`
- `[publish].maven_user` / `maven_password`
- `[publish].modrinth_token` / `curseforge_token`

## Configuration Reference

### `[mod]` — mod identity

This is the first block every project changes.

| Key | Meaning |
|---|---|
| `mod_id` | NeoForge mod id |
| `mod_name` | player-facing display name |
| `version` | base version |
| `version_suffix` | optional version suffix |
| `group` | Maven group |
| `authors` | non-empty author list |
| `license` | license identifier |
| `description` | mod description |
| `credits` | optional credits |
| `issue_tracker_url` | optional issue tracker URL |

### `[features]` — ecosystem feature switches

Curated feature switches on this branch:

- `jei`
- `curios`
- `mixin_extras`

`geckolib` and `player_animator` stay off for now. Until compatible `26.1.2` artifacts exist, enabling them fails during configuration.

Keep unused ones set to `false`.

### `[languages]` — Java/Kotlin switches

Java is the default path and is always enabled. Kotlin is optional; when enabled, sources in `src/main/kotlin` compile alongside `src/main/java`:

```toml
[languages]
kotlin = true
```

Recommended priority is Java > Kotlin > native. Use Java for the normal NeoForge surface, Kotlin when its syntax or libraries are useful, and native libraries only for advanced prebuilt JNI/JNA integrations.

### `[overrides]` — version overrides

Use this only when a feature is enabled but you need a different version than the template default.

Currently usable keys:

- `jei_version`
- `curios_version`
- `mixin_extras_version`

### `[dev_packs]` — local helper packs

This branch only keeps local helper packs that have been re-curated for this version.

Currently supported:

- `basic`: JEI + Jade
- `appleskin`: AppleSkin
- `curios`: Curios

It only affects the local runtime environment. It does not define your published API surface.

### `[repositories]` — extra Maven repositories

Common ecosystem repositories are already included. Only add entries here when a dependency lives outside the built-in set:

```toml
[repositories]
custom_repo = "https://maven.example.com/releases"
```

Inline-table form is also supported:

```toml
[repositories]
custom_repo = { url = "https://maven.example.com/releases", name = "Example", groups = ["com.example"] }
```

### `[dependencies.*]` / `[embedded_projects.*]` — extra dependencies and embedded subprojects

Most extra dependencies should be declared here rather than by editing `build.gradle`.

Common buckets:

- `api`
- `implementation`
- `compile_only_api`
- `compile_only`
- `runtime_only`
- `annotation_processor`
- `test_implementation`
- `test_runtime_only`
- `deobf_api`
- `deobf_implementation`
- `deobf_compile_only_api`
- `deobf_compile_only`
- `deobf_runtime_only`
- `deobf_test_implementation`
- `deobf_test_runtime_only`
- `jarjar`

Gradle subprojects belong under:

- `[embedded_projects.api]`
- `[embedded_projects.implementation]`

The practical distinction is:

- `jarjar` decides whether an external dependency is bundled into the final jar
- `embedded_projects.*` decides whether a Gradle subproject is bundled into the main mod
- `api` / `compile_only_api` decide whether downstream builds can compile against it

### `[native_libraries.*]` — prebuilt native libraries

This advanced section packages prebuilt JNI/JNA binaries. It does not compile Rust, C, or C++ source code.

```toml
[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["windows-x86_64", "linux-x86_64", "macos-aarch64"]
required = true
```

Files must match the generated platform file names:

```text
native-libs/
  physics/
    windows-x86_64/pickaid_physics.dll
    linux-x86_64/libpickaid_physics.so
    macos-aarch64/libpickaid_physics.dylib
```

The build packages those files into the jar and generates a Java `NativeLibraries` helper. At runtime, call `load("physics")` from `${group}.${mod_id}.runtime.NativeLibraries`; for JNA, use the returned `Path` when binding the library.

#### JNI: call your own native methods from Java or Kotlin

Assume this project config:

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

The generated helper package is `com.example.physicsmod.runtime.NativeLibraries`. Load the library before declaring or calling native methods:

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

Place compiled outputs in the template's native layout. macOS aarch64 example:

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

#### JNA: bind an existing C ABI library

Use JNA when the native library already exports plain C functions and you do not want JNI glue code. Bundle JNA first:

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

The C library only needs to export a plain function:

```c
int add(int left, int right) {
    return left + right;
}
```

Rule of thumb: use JNI for performance-sensitive bridge code or JVM interaction; use JNA for existing C ABI libraries.

### Usage combinations

#### Java only

No extra setup is required. Keep:

```toml
[languages]
kotlin = false
```

Put source in `src/main/java`; this is the normal Java/NeoForge path.

#### Kotlin only

Enable Kotlin and place mod code in `src/main/kotlin`. The Java toolchain still stays enabled because NeoForge, annotation processing, and generated sources use Java infrastructure.

```toml
[languages]
kotlin = true
```

#### Java + Kotlin

Enable Kotlin and use both `src/main/java` and `src/main/kotlin`. Java can call Kotlin JVM APIs such as `@JvmStatic` members, and Kotlin can call Java classes directly.

```toml
[languages]
kotlin = true
```

#### Java + native

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

#### Java + Kotlin + native

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

### `[metadata]` — mod display metadata

This block feeds `neoforge.mods.toml`.

The fields currently exposed by the template are:

- `logo_file`
- `logo_blur`
- `show_as_resource_pack`
- `show_as_data_pack`
- `update_json_url`
- `display_url`
- `display_test` (`MATCH_VERSION`, `IGNORE_SERVER_VERSION`, `IGNORE_ALL_VERSION`, or `NONE`)

### `[mod_relations.*]` — mod relation declarations

This branch can express these relation types directly:

- `required`
- `optional`
- `incompatible`
- `discouraged`
- `embedded`

String shorthand means "version range only":

```toml
[mod_relations.required]
curios = "[15.0.0-beta.2,)"
```

On this branch, every relation except `embedded` must define `version_range`. When you use the inline-table form, `ordering` must be `NONE`, `BEFORE`, or `AFTER`, and `side` must be `BOTH`, `CLIENT`, or `SERVER`.

The fuller form can also include:

- `mod_id`
- `version_range`
- `ordering`
- `side`
- `reason`
- `referral_url`
- `modrinth`
- `curseforge`

Example:

```toml
[mod_relations.optional]
jade = { version_range = "*", modrinth = "nvQzSEkH", curseforge = "324717" }

[mod_relations.incompatible]
old_renderer = { version_range = "*", reason = "Hooks the same render pipeline" }
```

`embedded` is upload-platform metadata only, so it must define at least one `modrinth` or `curseforge` project id.

### `[publish]` — publishing settings

This block controls:

- `maven_url`
- `curseforge_project`
- `modrinth_project`
- `release_type`

Sensitive values should usually live in environment variables or `project.local.toml`.

Common environment variables:

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

### `[naming]` — artifact naming

This controls the final jar name.

Supported tokens:

- `{archive_name}`
- `{mod_id}`
- `{version}`
- `{mc_version}`
- `{loader}`

Default form:

```toml
jar_format = "{archive_name}-{mc_version}-{version}"
```

## Project Layout

### `project.toml`

Main project configuration for mod identity, dependencies, publishing, and naming.

### `project.local.toml`

Machine-local settings that should not go into git.

### `src/main/java`

Primary source directory. The sample entrypoint and sample mixin live here.

### `src/templates/META-INF`

The source template for `neoforge.mods.toml`. You only need to touch it when you want to change generated metadata structure.

### `src/templates/mixins.json`

The shared Mixin config template.

## Publishing Guide

### Publish to local Maven

```bash
./gradlew publishToMavenLocal
```

### Publish to remote Maven

```bash
./gradlew publish
```

That requires `publish.maven_url` or `MAVEN_URL`, plus credentials when the repository needs them.

### Upload to Modrinth / CurseForge

```bash
./gradlew buildAndUploadMod
```

That assumes:

- the corresponding project ids are already set in `project.toml`
- the matching tokens are available through environment variables or `project.local.toml`

## Artifacts

The main Maven publication surface on this branch is:

- the main jar
- the `sources` jar
- the `javadoc` jar

A `deobf` helper jar is also built for development-oriented use.

Platform uploads use the main jar.

## How Downstream Mods Depend On It

A normal downstream consumer usually writes:

```gradle
repositories {
    maven { url = "https://your-maven.example/releases" }
}

dependencies {
    implementation "com.yourname.yourmod:yourmod:1.0.0"
}
```

If your own source code directly imports APIs from libraries that the mod also exposes, such as JEI or Curios, you still need to declare those APIs in your own build.

## Gradle Mirrors

The repository should keep the official Gradle Wrapper URL.

If downloads are slow on your machine, switch to a mirror locally and switch back before committing.

## Common Commands

```bash
./gradlew build
./gradlew runClient
./gradlew runServer
./gradlew runData
./gradlew publishToMavenLocal
./gradlew publish
./gradlew buildAndUploadMod
```

## FAQ

### Why does this branch not use `genIntellijRuns`?

Because it already uses the official `ModDevGradle` flow. Import the Gradle project and sync it in the IDE.

### What is the difference between `embedded_projects.*` and `mod_relations.embedded`?

They are different things:

- `embedded_projects.*` means bundling Gradle subprojects into the main mod
- `mod_relations.embedded` means declaring an embedded-library relation for Modrinth / CurseForge

### How do I express a required version range for another mod?

Use `version_range` inside `mod_relations.*`:

```toml
[mod_relations.required]
curios = "[15.0.0-beta.2,16.0.0)"
```
