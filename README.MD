<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft Forge Mod 开发模板

[English Version](README_EN.md) | 中文版

这是一个面向 Minecraft 1.20.1 Forge 的模板。

它已经把常见的项目骨架、可选库接入、Maven 发布、`runtime` 分发包、Modrinth 和 CurseForge 上传规则整理好了。你改完 `template.toml` 和包名，就可以直接开始写模组。

`build.txt` 已经退场。现在只认 `template.toml`。

## 快速开始

### 1. 获取模板

```bash
git clone [仓库地址]
cd PickAIDForgeTemplate
```

### 2. 修改 `template.toml`

最少先改这几块：

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

### 3. 改掉模板占位路径

把下面这些占位内容换成你自己的：

1. `src/main/java/org/pickaid/modid/`
2. `src/main/resources/assets/modid/`
3. `src/main/resources/mixins.modid.json`
4. `src/main/java/org/pickaid/modid/Example.java`

如果你不用 Mixin，可以保留空的配置；如果要用，就把包路径和文件名一起改掉。

### 4. 导入 IDEA 并生成运行配置

```bash
./gradlew genIntellijRuns
./gradlew build
```

## `template.toml` 怎么写

### `[mod]`

这里放模组本身的信息。

- `mod_id` 是模组 id。
- `mod_name` 是显示名称。
- `version` 是基础版本。
- `version_suffix` 可选，比如 `hotfix.2`。
- `group` 是 Maven group。
- `authors` 不能为空。
- `description` 会写进 `mods.toml`。

如果你把 `version = "1.0.0"`、`version_suffix = "hotfix.2"`，最终版本就是 `1.0.0-hotfix.2`。

### `[features]`

这里决定模板是否接入常见库：

- `jei`
- `curios`
- `geckolib`
- `player_animator`
- `kubejs`
- `mixin_extras`

布尔值写 `true` 或 `false`。

### `[overrides]`

这里用来覆盖模板默认版本。

只有在对应 feature 已开启时，相关 override 才允许出现。当前支持：

- `jei_version`
- `curios_version`
- `geckolib_version`
- `player_animator_version`
- `bendylib_version`
- `kubejs_version`
- `rhino_version`
- `architectury_version`
- `mixin_extras_version`

`player_animator` 如果开了，通常也要一起关心 `bendylib_version`。
`kubejs` 这组会一起牵涉 `kubejs_version`、`rhino_version`、`architectury_version`。

### `[publish]`

这里控制 Maven 和平台上传。

- `maven_url` 为空时，不做远端 Maven 发布。
- `curseforge_project = 0` 表示不上传 CurseForge。
- `modrinth_project = ""` 表示不上传 Modrinth。
- `release_type` 只接受 `alpha`、`beta`、`release`。

`buildAndUploadMod` 至少要有一个平台目标。某个平台留空，就等于这个平台不参与上传。

### `[naming]`

- `archive_name` 控制基础 artifact 名。
- `jar_format` 控制 jar 文件名格式。

支持的 token 只有这些：

- `{archive_name}`
- `{mod_id}`
- `{version}`
- `{mc_version}`
- `{loader}`

默认格式是：

```toml
jar_format = "{archive_name}-{mc_version}-{version}"
```

## 发布出来的东西是什么

这个模板会发布四类文件：

- 默认 artifact：开发用主 jar
- `runtime` 分类 artifact：分发用打包 jar
- `sources` jar
- `javadoc` jar

需要记住的是：

- 默认 Maven 坐标是开发 jar，不是分发 jar。
- `runtime` jar 才是上传到 Modrinth 和 CurseForge 的那一个。
- Modrinth 和 CurseForge 上传时都会强制走 `runtime` jar。

## 从别的模组里怎么引用

如果你把这个模板产出的模组发布到 Maven，下游通常这样写：

```gradle
repositories {
    maven { url = "https://your-maven.example/releases" }
}

dependencies {
    implementation "com.yourname.yourmod:yourmod:1.0.0"
}
```

这里不要再包一层 `fg.deobf(...)`。默认发布物本来就是开发用 jar。

如果你只是想在运行时拿到打包版，可以再用 `runtime` 分类：

```gradle
runtimeOnly "com.yourname.yourmod:yourmod:1.0.0:runtime"
```

如果你的项目直接引用了这个模组暴露出来的某些可选库 API，比如 JEI 或 Curios，自家项目里还是应该明确声明这些 API 依赖。模板发布的 POM 会带基础依赖信息，但不会替你决定源码层该依赖什么。

## 环境变量

构建和发布会优先读取这些环境变量：

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

例如：

```bash
export MAVEN_USER="your-user"
export MAVEN_PASSWORD="your-password"
export MODRINTH_TOKEN="your-token"
export CURSEFORGE_TOKEN="your-token"
```

## 常用命令

```bash
./gradlew build
./gradlew runClient
./gradlew runServer
./gradlew runData
./gradlew genIntellijRuns
./gradlew publishToMavenLocal
./gradlew buildAndUploadMod
```

## 常见问题

### 发现还在读 `build.txt`

不会。

如果根目录里还有旧的 `build.txt`，构建会直接停下，提醒你迁移到 `template.toml`。

### 本地 Maven 里要拿哪个坐标

开发依赖拿默认坐标：

```gradle
implementation "group:modid:version"
```

分发包或运行时打包依赖拿：

```gradle
runtimeOnly "group:modid:version:runtime"
```

### 上传失败

先看这几件事：

1. `modrinth_project` 或 `curseforge_project` 是否至少配了一个。
2. 对应 token 环境变量是否真的存在。
3. `release_type` 是否是 `alpha`、`beta`、`release` 之一。

### 资源或 Mixin 没生效

通常就是模板占位路径没改干净。重点检查：

- `org.pickaid.modid`
- `assets/modid`
- `mixins.modid.json`

## 许可证

本模板使用 MIT License。
