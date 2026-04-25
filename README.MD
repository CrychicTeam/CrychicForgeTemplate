<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate — Forge 1.19.2 模组模板

[English Version](README_EN.md) | 中文版

`PickAIDForgeTemplate-1.19.2` 只服务于 `Forge 1.19.2`。这条分支已经按 `1.19.2` 的实际生态重新校准，`project.toml` 里的内置版本、CurseMaven file id、本地调试包和发布脚本都对应这一版，不再混着 `1.20.1` 的旧值。

这支模板的目标很直接：

- 新项目主要改 `project.toml`
- 常见生态依赖尽量不再手改 `build.gradle`
- 本地调试包、发布配置、产物命名都走统一配置
- 先把项目跑起来，再开始写模组逻辑

## 先知道这件事

版本是按 branch 管的，不是按 profile 管的。

也就是说：

- 这条分支只负责 `Forge 1.19.2`
- 不接受 `project.toml [platform]`
- 不接受 `-PtemplateProfile=...`
- `build.txt` 和 `template.toml` 都已经废弃

## 这条分支当前预置了什么

- `Forge 1.19.2` + `ModDevGradle LegacyForge`
- `project.toml` 单入口配置
- 内置 feature 开关：`jei`、`curios`、`geckolib`、`player_animator`、`mixin_extras`
- 内置本地调试包：`basic`、`appleskin`、`combat`、`curios`、`spell`、`kubejs`
- Maven 发布、Modrinth / CurseForge 上传任务
- 共享的 Mixin 模板和 `mods.toml` 模板

## 快速开始

### 1. 先改 `project.toml`

通常先改这几项就够了：

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

如果要做测试版或热修：

```toml
version = "1.2.0"
version_suffix = "hotfix.1"
```

最终版本会变成 `1.2.0-hotfix.1`。

### 2. 替换示例代码

通常先看这几个位置：

1. `src/scaffolds/legacy-forge/java/org/pickaid/example/Example.java`
2. `src/scaffolds/legacy-forge/templates/META-INF/mods.toml`
3. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
4. `src/templates/mixins.json`

如果你的项目不用 Mixin，就删掉示例 Mixin 和对应模板。

### 3. 先跑一次 Gradle

```bash
./gradlew help
./gradlew build
```

能过这一步，说明模板已经基本切到你的项目名下了。

## `project.toml` 里最常用的块

### `[mod]`

模组的身份信息，最先改这里：

- `mod_id`
- `mod_name`
- `version`
- `version_suffix`
- `group`
- `authors`
- `license`
- `description`

### `[features]`

模板直接帮你接好的常见生态开关：

- `jei`
- `curios`
- `geckolib`
- `player_animator`
- `mixin_extras`

### `[dev_packs]`

这些是本地开发辅助包，不是你正式对外的 API 面。

当前内置：

- `basic`: JEI + Jade
- `appleskin`: AppleSkin
- `combat`: Target Dummy + AttributeFix + Max Health Fix
- `curios`: Curios 本地运行时
- `spell`: Caelus + Iron's Spellbooks
- `kubejs`: Architectury + Rhino + KubeJS 本地运行时

`kubejs` 这组现在已经按 `1.19.2` 的实际版本重新校准，可以直接拿来做本地脚本测试。

### `[repositories]` 和 `[dependencies.*]`

额外仓库和依赖尽量都走这里，不要再把 `build.gradle` 改回一堆硬编码。

常用依赖桶：

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

`project.toml` 里已经给了 1.19.2 对应的示例坐标，直接取消注释再按需调整即可。

## 本机私有配置

`project.local.toml` 不进 git，适合放：

- `[run].mc_user`
- Maven 用户名和密码
- Modrinth / CurseForge token

可以从 [`project.local.toml.example`](/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate-1.19.2/project.local.toml.example) 复制。

## 发布

发布配置也走 `project.toml` / `project.local.toml`。

更顺手的做法是：

1. 仓库地址放 `project.toml`
2. 用户名、密码、token 放 `project.local.toml` 或环境变量

支持的环境变量：

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

## 常用命令

```bash
./gradlew help
./gradlew build
./gradlew publishToMavenLocal
./gradlew validateUploadConfiguration
```
