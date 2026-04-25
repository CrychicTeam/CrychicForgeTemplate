<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft Forge Mod Template

English | [中文版](README.MD)

This template targets Minecraft `1.20.1` on Forge. It is meant to be the place where you change `project.toml`, rename the placeholder package, and start building the mod instead of reworking Gradle every time.

Out of the box it already gives you:

- a working Forge project skeleton
- curated switches for common mod integrations
- Maven publication with `sources`, `javadoc`, and `runtime` jars
- Modrinth and CurseForge upload wiring
- a TOML-based way to add more repositories and dependencies without editing `build.gradle`

`template.toml` and `build.txt` are retired. This template reads `project.toml` and can also read an ignored `project.local.toml`.

## Quick Start

### 1. Clone and open the template

```bash
git clone [repository-url]
cd PickAIDForgeTemplate
```

### 2. Edit `project.toml`

At minimum, change the mod identity and naming:

```toml
schema_version = 1
template_version = "1.20.1-template-1.0.0"

[mod]
mod_id = "yourmod"
mod_name = "Your Mod"
version = "1.0.0"
version_suffix = ""
group = "com.yourname.yourmod"
authors = ["Your Name"]
license = "MIT"
description = "What this mod does."

[features]
jei = false
curios = false
geckolib = false
player_animator = false
mixin_extras = true

[dev_packs]
basic = false
appleskin = false
combat = false
curios = false
spell = false
kubejs = false

[publish]
maven_url = ""
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "yourmod"
jar_format = "{archive_name}-{mc_version}-{version}"
```

`version_suffix` is optional. If you set:

```toml
version = "1.2.0"
version_suffix = "hotfix.1"
```

the final version becomes `1.2.0-hotfix.1`.

### 3. Rename the template placeholders

Replace these before writing real code:

1. `src/scaffolds/legacy-forge/java/org/pickaid/example/Example.java`
2. `src/scaffolds/legacy-forge/templates/META-INF/mods.toml`
3. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
4. `src/templates/mixins.json`

If you do not use Mixin, remove the sample mixin and `src/templates/mixins.json` together.

### 4. Generate runs and build once

```bash
./gradlew genIntellijRuns
./gradlew build
```

### 5. Optional: add `project.local.toml`

This file is ignored by default and is where machine-local values belong:

- `mc_user`
- temporary local publishing credentials
- local compatibility toggles

You can start from [`project.local.toml.example`](project.local.toml.example).

## `project.toml` Reference

### `[mod]`

This is the mod identity block.

- `mod_id`: the Forge mod id
- `mod_name`: display name
- `version`: base version
- `version_suffix`: optional suffix such as `beta.2` or `hotfix.1`
- `group`: Maven group
- `authors`: non-empty author list
- `license`: license string written into metadata
- `description`: mod description written into `mods.toml`

### `[features]`

These are the built-in switches for integrations the template supports directly:

- `jei`
- `curios`
- `geckolib`
- `player_animator`
- `mixin_extras`

Use `true` or `false`.

### `[overrides]`

Use this when you want to override the curated versions shipped by the template.

Supported keys:

- `jei_version`
- `curios_version`
- `geckolib_version`
- `player_animator_version`
- `bendylib_version`
- `mixin_extras_version`

Each override is only valid when its matching feature is enabled.
In normal use, leave this block empty unless you intentionally want to diverge from the template defaults.

### `[dev_packs]`

This is for grouped local testing mods. They only affect the development runtime and are not meant to define your published API surface.

Built-in packs:

- `basic`: JEI, Jade
- `appleskin`: AppleSkin
- `combat`: Target Dummy, AttributeFix, Max Health Fix
- `curios`: local Curios runtime
- `spell`: Caelus, Iron's Spellbooks
- `kubejs`: local Architectury, Rhino, and KubeJS runtime

Enable them directly:

```toml
[dev_packs]
basic = true
appleskin = false
combat = true
curios = false
spell = false
kubejs = false
```

Use this when you want a ready-to-run local environment for recipe lookup, entity inspection, combat balancing, Curios slot testing, or KubeJS-based smoke testing.

If you need to compile against the JEI API in code, you should still enable `[features].jei`. The `basic` pack only adds JEI and Jade to the local runtime.
If you need to compile against Curios or KubeJS APIs in code, you should still declare them explicitly through `[features]` or `[dependencies.*]`. The `curios` and `kubejs` packs only add local runtime support.

### `[repositories]`

Use this when an extra dependency needs another Maven repository.
Common ecosystem repositories for Registrate, JEI, Curios, GeckoLib, MixinExtras, Architectury, Latvian/KubeJS, CurseMaven, and KosmX are already supplied by the template defaults, so you only need this block for project-specific additions.

```toml
[repositories]
architectury = "https://maven.architectury.dev"
latvian = "https://maven.latvian.dev/releases"
```

Inline table form is also supported when you want an explicit display name or content filter:

```toml
[repositories]
spell_repo = { url = "https://code.redspace.io/releases", name = "Redspace", groups = ["io.redspace.ironsspellbooks"] }
```

### `[dependencies.*]`

This is the main "extra dependencies" area.

For most projects, this is enough. You should not need to keep editing `build.gradle` every time you add one more library or mod.

Supported buckets:

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

Gradle subprojects do not go under `[dependencies.*]`. They use `[embedded_projects.*]` instead.

If you only want the short version:

- `deobf_api`: another mod's types appear in your own public API, so downstream consumers must also see it
- `deobf_implementation`: your mod uses that mod internally
- `deobf_compile_only`: needed to compile, but not part of your runtime bundle
- `deobf_runtime_only`: only needed when you launch locally

For normal non-mod libraries, use the same buckets without the `deobf_` prefix.

Simple entries use string shorthand:

```toml
[dependencies.deobf_api]
registrate = "com.tterrag.registrate:Registrate:MC1.20-1.3.2"

[dependencies.deobf_compile_only]
kubejs = "dev.latvian.mods:kubejs-forge:2001.6.4-build.120"
rhino = "dev.latvian.mods:rhino-forge:2001.2.2-build.18"
```

Advanced entries use inline tables:

```toml
[dependencies.deobf_implementation]
architectury = { notation = "dev.architectury:architectury-forge:9.1.12", transitive = false }
```

If a pack is already enabled in `[dev_packs]`, do not duplicate the same helper mods manually under `[dependencies.*]`.

The easy way to think about `jarjar` is this:

- `jarjar` decides whether something is bundled into your final jar
- `api` / `compile_only_api` decide whether downstream consumers can compile against it

The three common cases are:

1. Bundle an external helper library and keep it internal:

```toml
[dependencies.jarjar]
helper = { notation = "com.example:helper-forge:1.0.0", range = "[1.0.0,)" }
```

2. Bundle an external library and also let downstream consumers compile against its types:

```toml
[dependencies.compile_only_api]
helper_api = { notation = "com.example:helper-forge:1.0.0", range = "[1.0.0,)" }
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

### `[publish]`

This controls Maven and platform publishing.

- `maven_url`: remote Maven repository, or empty string to skip remote Maven publish
- `curseforge_project`: CurseForge project id, or `0` to disable CurseForge upload
- `modrinth_project`: Modrinth project id, or empty string to disable Modrinth upload
- `release_type`: `alpha`, `beta`, or `release`

Environment variables can override the sensitive parts:

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

The better local-only place for these values is the ignored `project.local.toml`:

```toml
[publish]
maven_user = "your-user"
maven_password = "your-password"
modrinth_token = "your-modrinth-token"
curseforge_token = "your-curseforge-token"
```

`mc_user` also belongs in that local file rather than `project.toml`:

```toml
[run]
mc_user = "DevPlayer,00000000000000000000000000000001"
```

That split is intentional:

- these are machine- or account-specific values, not shared project config
- switching machines should not dirty the repo
- UUIDs and publish credentials should not land in git history

`project.toml` still accepts publish credentials as temporary fallbacks, but the intended path is environment variables or `project.local.toml`.

Example:

```bash
export MAVEN_USER="your-user"
export MAVEN_PASSWORD="your-password"
export MODRINTH_TOKEN="your-modrinth-token"
export CURSEFORGE_TOKEN="your-curseforge-token"
```

### `[naming]`

- `archive_name`: base artifact name
- `jar_format`: jar file name format

Supported tokens:

- `{archive_name}`
- `{mod_id}`
- `{version}`
- `{mc_version}`
- `{loader}`

Default:

```toml
jar_format = "{archive_name}-{mc_version}-{version}"
```

## Publishing

## Gradle Download Mirrors

The repository keeps the official Wrapper URL by default:

- `https://services.gradle.org`

If downloads are slow in your region, change `distributionUrl` in `gradle/wrapper/gradle-wrapper.properties` on your own machine instead of committing a region-specific mirror URL.

The practical rule is:

- keep the repo on the official URL
- switch locally if you need a mirror
- switch back before you commit

For mainland China development environments, an Aliyun or Huawei Cloud Gradle mirror is usually the first thing worth trying.

### Publish to local Maven

```bash
./gradlew publishToMavenLocal
```

### Publish to your own Maven

1. Set `publish.maven_url` in `project.toml`, or provide `MAVEN_URL`.
2. Export `MAVEN_USER` and `MAVEN_PASSWORD` if the repository needs auth.
3. Run:

```bash
./gradlew publish
```

### Upload to Modrinth or CurseForge

Fill the matching project id in `project.toml`, export the matching token, then run:

```bash
./gradlew buildAndUploadMod
```

This task always uploads the packaged `runtime` jar, not the development jar.
You can use `publish.modrinth_token` or `publish.curseforge_token` temporarily for local runs, but environment variables are the intended release path.

## What gets published

The Maven publication contains:

- the default development jar
- the `runtime` jar
- the `sources` jar
- the `javadoc` jar

The important rule is simple:

- Maven consumers compile against the default artifact
- platform uploads ship the `runtime` artifact

## How another mod should depend on it

For normal development, downstream mods should use the default Maven coordinate:

```gradle
repositories {
    maven { url = "https://your-maven.example/releases" }
}

dependencies {
    implementation "com.yourname.yourmod:yourmod:1.0.0"
}
```

Do not wrap that published default artifact in `fg.deobf(...)`. The default published jar is already the development jar.

If you need the packaged runtime artifact itself, use the classifier explicitly:

```gradle
runtimeOnly "com.yourname.yourmod:yourmod:1.0.0:runtime"
```

If your own code imports APIs from optional libraries exposed by that mod, such as JEI or Curios, declare those APIs in your own build too. Publishing the mod does not automatically turn those libraries into a complete public API surface for downstream source code.

## Common Commands

```bash
./gradlew build
./gradlew runClient
./gradlew runServer
./gradlew runData
./gradlew genIntellijRuns
./gradlew publishToMavenLocal
./gradlew publish
./gradlew buildAndUploadMod
```

## FAQ

### How do I add KubeJS now?

Use the generic dependency section instead of a built-in feature:

```toml
[repositories]
architectury = "https://maven.architectury.dev"
latvian = "https://maven.latvian.dev/releases"

[dependencies.deobf_compile_only]
kubejs = "dev.latvian.mods:kubejs-forge:2001.6.4-build.120"
rhino = "dev.latvian.mods:rhino-forge:2001.2.2-build.18"

[dependencies.deobf_implementation]
architectury = { notation = "dev.architectury:architectury-forge:9.1.12", transitive = false }
```

### Something still tries to use `build.txt` or `template.toml`

That is intentional. Old config files hard-fail so the project does not silently drift between formats. Delete them and keep everything in `project.toml`.

### When should I use `fg.deobf(...)`?

When you add mod dependencies through `project.toml`, the `deobf_*` buckets already handle that for you. When you consume a mod published by this template from Maven, use the normal dependency coordinate instead.
