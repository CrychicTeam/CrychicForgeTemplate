<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft NeoForge 1.21.1 Mod Template

English | [中文版](README.MD)

This branch is only for `NeoForge 1.21.1`.

If you need another Minecraft version, switch to the matching branch. Do not try to select versions inside `project.toml`, and do not pass `-PtemplateProfile=...`.

This template now has a narrow focus:

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

This branch's `neoforge.mods.toml` template. The build expands it into the generated metadata file.

### `src/templates/mixins.json`

Shared Mixin configuration template. The build turns it into `${mod_id}.mixins.json`.

## Scope of This Branch

This branch is now explicitly `NeoForge 1.21.1 + ModDevGradle`.

- no `[platform]`
- no `-PtemplateProfile=...`
- no `build.txt`

If you need another Minecraft version, move to the matching version branch.
