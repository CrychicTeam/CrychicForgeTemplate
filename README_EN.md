<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft NeoForge 1.21.1 Mod Template

English | [中文版](README.MD)

This branch has one job: give you a clean `NeoForge 1.21.1` starting point.

If you need another Minecraft version, switch to the matching branch. Do not try to select versions inside `project.toml`, and do not pass `-PtemplateProfile=...`.

The rules on this branch are straightforward:

- keep the main project config in `project.toml`
- use official `ModDevGradle`
- stop carrying old `build.txt` flows
- keep publishing, dependency setup, and Mixin config data-driven

## Fastest Start

### 1. Edit `project.toml`

These are usually the first values you change:

```toml
schema_version = 1
template_version = "1.21.1-template-1.0.0"

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

### 2. Replace the sample files

Start with these:

1. `src/main/java/org/pickaid/example/Example.java`
2. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
3. `src/scaffolds/modern-neoforge/templates/META-INF/neoforge.mods.toml`
4. `src/templates/mixins.json`

If you do not use Mixin, delete the sample mixin and the shared mixin template together.

### 3. Import the Gradle project and build once

```bash
./gradlew help
./gradlew build
```

This is a `ModDevGradle` branch, so the old `genIntellijRuns` pattern is no longer the right workflow. Import the Gradle project and let your IDE sync.

## Common Commands

```bash
./gradlew runClient
./gradlew runServer
./gradlew runData
./gradlew publishToMavenLocal
```

## Using `jarjar` without fighting the build

The short version is:

- `jarjar` decides whether something is bundled into your final jar
- `api` / `compile_only_api` decide whether downstream consumers can compile against it
- `[embedded_projects.*]` decide whether Gradle subprojects get bundled into the main mod

The three common cases are:

1. Bundle an external helper library and keep it internal:

```toml
[dependencies.jarjar]
helper = { notation = "com.example:helper-neoforge:1.0.0", range = "[1.0.0,)" }
```

2. Bundle an external library and also let downstream consumers compile against it:

```toml
[dependencies.compile_only_api]
helper_api = { notation = "com.example:helper-neoforge:1.0.0", range = "[1.0.0,)" }
```

That `range` entry tells the template to feed the same dependency into `jarjar`.
If your own project should use it at runtime too, use `api` or `implementation` with the same `range` pattern.

3. Bundle Gradle subprojects into the main mod:

```toml
[embedded_projects.api]
core = ":core"
# core = { path = ":core", configuration = "namedElements" }

[embedded_projects.implementation]
internal = ":internal"
```

- `[embedded_projects.api]`: bundle the subproject and let downstream builds compile against it through the main published artifact.
- `[embedded_projects.implementation]`: bundle the subproject but keep it internal to the main mod.

## Files You Will Touch Often

### `project.toml`

This is the main configuration surface. It holds:

- mod identity
- feature switches
- the small set of branch-curated dev packs
- extra repositories
- extra dependencies
- publishing settings
- output naming

### `project.local.toml`

This stays out of git and is meant for machine-local settings such as:

- `mc_user`
- temporary Maven credentials
- Modrinth / CurseForge tokens

Start from [`project.local.toml.example`](project.local.toml.example).

### `src/main/java`

Standard Java source root. The sample mod entrypoint and sample mixin both live here.

### `src/scaffolds/modern-neoforge/templates`

This is the `neoforge.mods.toml` template used by the build. Touch it only when you need to change the generated mod metadata structure.

### `src/templates/mixins.json`

This is the shared Mixin config template. Change it only if you actually use Mixins; otherwise remove the sample together with the sample mixin class.

## Scope of This Branch

This branch is simply `NeoForge 1.21.1 + ModDevGradle`. It is not trying to carry the old template compatibility layers anymore.

- no `[platform]`
- no `-PtemplateProfile=...`
- no `build.txt`

If you need another Minecraft version, move to the matching version branch.
