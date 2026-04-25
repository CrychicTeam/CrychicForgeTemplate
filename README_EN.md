<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate — Forge 1.19.2 Mod Template

English | [中文版](README.MD)

`PickAIDForgeTemplate-1.19.2` is only for `Forge 1.19.2`. This branch has been re-curated against the real `1.19.2` ecosystem, so the built-in versions in `project.toml`, the CurseMaven file ids, the local helper packs, and the publishing scripts all line up with this branch instead of carrying old `1.20.1` values.

The point of this template is simple:

- edit `project.toml` first
- keep common dependency wiring out of handwritten `build.gradle`
- drive local helper packs, publishing, and artifact naming from one config surface
- get the project running first, then start writing mod code

## One Important Rule

Versions are managed by branch, not by profile.

That means:

- this branch only targets `Forge 1.19.2`
- it does not accept `project.toml [platform]`
- it does not accept `-PtemplateProfile=...`
- `build.txt` and `template.toml` are no longer valid here

## What This Branch Already Includes

- `Forge 1.19.2` on `ModDevGradle LegacyForge`
- a single TOML entry point through `project.toml`
- built-in feature switches for `jei`, `curios`, `geckolib`, `player_animator`, and `mixin_extras`
- built-in local helper packs for `basic`, `appleskin`, `combat`, `curios`, `spell`, and `kubejs`
- Maven publishing plus Modrinth / CurseForge upload tasks
- shared Mixin and `mods.toml` templates

## Quick Start

### 1. Edit `project.toml`

In most cases this is enough to start:

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

For preview or hotfix builds:

```toml
version = "1.2.0"
version_suffix = "hotfix.1"
```

This renders the final version as `1.2.0-hotfix.1`.

### 2. Replace the sample code

The first files you usually touch are:

1. `src/scaffolds/legacy-forge/java/org/pickaid/example/Example.java`
2. `src/scaffolds/legacy-forge/templates/META-INF/mods.toml`
3. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
4. `src/templates/mixins.json`

If your mod does not use Mixins, remove the sample mixin and the shared mixin template.

### 3. Run Gradle once

```bash
./gradlew help
./gradlew build
```

If that works, the template is basically switched over to your project.

## Most Common `project.toml` Blocks

### `[mod]`

This is the mod identity block:

- `mod_id`
- `mod_name`
- `version`
- `version_suffix`
- `group`
- `authors`
- `license`
- `description`

### `[features]`

Built-in feature switches:

- `jei`
- `curios`
- `geckolib`
- `player_animator`
- `mixin_extras`

### `[dev_packs]`

These are local development helper packs, not your published API surface.

Built in right now:

- `basic`: JEI + Jade
- `appleskin`: AppleSkin
- `combat`: Target Dummy + AttributeFix + Max Health Fix
- `curios`: Curios local runtime
- `spell`: Caelus + Iron's Spellbooks
- `kubejs`: Architectury + Rhino + KubeJS local runtime

The `kubejs` pack is now re-curated for real `1.19.2` development instead of pointing at newer branch values.

### `[repositories]` and `[dependencies.*]`

Put extra repositories and dependencies here instead of growing `build.gradle` back into a pile of hardcoded coordinates.

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

The commented examples in `project.toml` already use `1.19.2`-correct coordinates, so you can usually start by uncommenting and adjusting them.

## Local-Only Settings

`project.local.toml` stays out of git and is the right place for:

- `[run].mc_user`
- local Maven credentials
- Modrinth / CurseForge tokens

Start from [`project.local.toml.example`](/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate-1.19.2/project.local.toml.example).

## Publishing

Publishing is driven by `project.toml` and `project.local.toml`.

The practical setup is:

1. keep repository URLs in `project.toml`
2. keep credentials and tokens in `project.local.toml` or environment variables

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
