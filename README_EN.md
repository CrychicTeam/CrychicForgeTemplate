<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft Forge Mod Template

English | [中文版](README.MD)

This is a Minecraft 1.20.1 Forge template.

It already sets up the usual project skeleton, optional library integration, Maven publishing, a `runtime` distribution jar, and upload rules for Modrinth and CurseForge. Change `template.toml`, rename the placeholder package, and start writing your mod.

`build.txt` is retired. The template now reads only `template.toml`.

## Quick Start

### 1. Get the template

```bash
git clone [repository-url]
cd PickAIDForgeTemplate
```

### 2. Edit `template.toml`

Start by changing these sections:

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
kubejs = true
mixin_extras = true

[publish]
maven_url = "https://your-maven.example/releases"
curseforge_project = 0
modrinth_project = ""
release_type = "alpha"

[naming]
archive_name = "yourmod"
jar_format = "{archive_name}-{mc_version}-{version}"
```

### 3. Replace the template placeholders

Rename these paths before you start real work:

1. `src/main/java/org/pickaid/modid/`
2. `src/main/resources/assets/modid/`
3. `src/main/resources/mixins.modid.json`
4. `src/main/java/org/pickaid/modid/Example.java`

If you do not use Mixin yet, you can keep the config empty. If you do use it, rename the package path and the file together.

### 4. Import into IntelliJ and generate runs

```bash
./gradlew genIntellijRuns
./gradlew build
```

## How `template.toml` works

### `[mod]`

This section holds the mod identity.

- `mod_id` is the mod id.
- `mod_name` is the display name.
- `version` is the base version.
- `version_suffix` is optional, for example `hotfix.2`.
- `group` is the Maven group.
- `authors` must not be empty.
- `description` is written into `mods.toml`.

If you set `version = "1.0.0"` and `version_suffix = "hotfix.2"`, the final version becomes `1.0.0-hotfix.2`.

### `[features]`

This section toggles common integrations:

- `jei`
- `curios`
- `geckolib`
- `player_animator`
- `kubejs`
- `mixin_extras`

Use `true` or `false`.

### `[overrides]`

This section overrides the template defaults.

An override is only valid when the owning feature is enabled. Current supported keys are:

- `jei_version`
- `curios_version`
- `geckolib_version`
- `player_animator_version`
- `bendylib_version`
- `kubejs_version`
- `rhino_version`
- `architectury_version`
- `mixin_extras_version`

If you enable `player_animator`, you will usually care about `bendylib_version` as well.
If you enable `kubejs`, that group also pulls in `kubejs_version`, `rhino_version`, and `architectury_version`.

### `[publish]`

This section controls Maven and platform uploads.

- `maven_url` empty means no remote Maven publish.
- `curseforge_project = 0` means no CurseForge upload.
- `modrinth_project = ""` means no Modrinth upload.
- `release_type` accepts only `alpha`, `beta`, or `release`.

`buildAndUploadMod` requires at least one platform target. Leaving a platform blank disables uploads for that platform.

### `[naming]`

- `archive_name` controls the base artifact name.
- `jar_format` controls the jar file names.

Supported tokens are:

- `{archive_name}`
- `{mod_id}`
- `{version}`
- `{mc_version}`
- `{loader}`

The default format is:

```toml
jar_format = "{archive_name}-{mc_version}-{version}"
```

## What gets published

The template publishes four artifact types:

- the default development jar
- the `runtime` classifier jar
- the `sources` jar
- the `javadoc` jar

The key points are:

- the default Maven coordinate is the development jar
- the `runtime` jar is the packaged distribution jar
- Modrinth and CurseForge always upload the `runtime` jar

## How another mod should depend on it

If you publish a mod built from this template to Maven, downstream projects will usually use it like this:

```gradle
repositories {
    maven { url = "https://your-maven.example/releases" }
}

dependencies {
    implementation "com.yourname.yourmod:yourmod:1.0.0"
}
```

Do not wrap that default artifact in `fg.deobf(...)`. The default published artifact is already the development jar.

If you need the bundled distribution jar at runtime, use the `runtime` classifier:

```gradle
runtimeOnly "com.yourname.yourmod:yourmod:1.0.0:runtime"
```

If your own project imports APIs from optional libraries exposed by this mod, such as JEI or Curios, declare those API dependencies directly in your own build as well. The published POM carries the basic dependency metadata, but it does not decide your source-level API surface for you.

## Environment Variables

The build reads these from the environment first:

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

Example:

```bash
export MAVEN_USER="your-user"
export MAVEN_PASSWORD="your-password"
export MODRINTH_TOKEN="your-token"
export CURSEFORGE_TOKEN="your-token"
```

## Common Commands

```bash
./gradlew build
./gradlew runClient
./gradlew runServer
./gradlew runData
./gradlew genIntellijRuns
./gradlew publishToMavenLocal
./gradlew buildAndUploadMod
```

## Common Issues

### Something still reads `build.txt`

It does not.

If an old `build.txt` is still sitting in the project root, the build stops immediately and tells you to move to `template.toml`.

### Which coordinate should I use from local Maven

Use the default coordinate for development:

```gradle
implementation "group:modid:version"
```

Use the packaged runtime jar only when you actually want the bundled runtime artifact:

```gradle
runtimeOnly "group:modid:version:runtime"
```

### Upload failed

Check these first:

1. At least one of `modrinth_project` or `curseforge_project` is configured.
2. The matching token environment variable is present.
3. `release_type` is one of `alpha`, `beta`, or `release`.

### Resources or Mixins do not load

This is usually a leftover template path. Check these first:

- `org.pickaid.modid`
- `assets/modid`
- `mixins.modid.json`

## License

This template is released under the MIT License.
