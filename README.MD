<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate — NeoForge 26.1 模组模板

[English Version](README_EN.md) | 中文版

`PickAIDForgeTemplate-26.1` 是面向 `Minecraft 26.1.2` / `NeoForge 26.1.x` 的模板分支。它用 `project.toml` 作为单一配置入口，把**模组信息、依赖、运行配置和发布链路**放在一套固定结构里，避免每个新项目都重新整理 Gradle。

## 目录

- [模板预置内容](#模板预置内容)
- [前置条件](#前置条件)
- [快速开始](#快速开始)
- [配置参考](#配置参考)
  - [[mod] — 模组身份](#mod--模组身份)
  - [[features] — 生态集成开关](#features--生态集成开关)
  - [[overrides] — 版本覆盖](#overrides--版本覆盖)
  - [[dev_packs] — 本地调试辅助包](#dev_packs--本地调试辅助包)
  - [[repositories] — 额外 Maven 仓库](#repositories--额外-maven-仓库)
  - [[dependencies.*] / [embedded_projects.*] — 额外依赖与嵌入子项目](#dependencies--embedded_projects--额外依赖与嵌入子项目)
  - [[metadata] — 模组展示信息](#metadata--模组展示信息)
  - [[mod_relations.*] — 模组关系声明](#mod_relations--模组关系声明)
  - [[publish] — 发布配置](#publish--发布配置)
  - [[naming] — 产物命名](#naming--产物命名)
- [目录结构](#目录结构)
- [发布指南](#发布指南)
- [产物说明](#产物说明)
- [下游模组如何依赖](#下游模组如何依赖)
- [Gradle 镜像](#gradle-镜像)
- [常用命令](#常用命令)
- [常见问题](#常见问题)

## 模板预置内容

克隆后即可直接使用的内容包括：

- **NeoForge 26.1 项目骨架**：基于官方 `ModDevGradle`
- **`project.toml` 配置驱动**：模组信息、依赖、发布走一套 TOML 结构
- **生态集成开关**：当前已校准 JEI、Curios、MixinExtras
- **本地调试辅助包**：`basic`、`appleskin`、`curios`
- **Maven 发布**：输出主 jar、sources、javadoc
- **Modrinth / CurseForge 上传**：可直接走上传任务，token 通过环境变量或本机私有 TOML 注入
- **TOML 依赖管理**：大多数额外依赖不需要再改 `build.gradle`

> 这条分支不接受 `build.txt`、`template.toml`、`[platform]` 或 `-PtemplateProfile=...` 这一类旧入口。

## 前置条件

- **JDK 25** 或允许 Gradle toolchain 自动下载 JDK 25
- 一个可用的 Gradle 环境（项目自带 Gradle Wrapper）
- 基本的 Minecraft Mod 开发概念（`mod_id`、Mixin、`neoforge.mods.toml`、Maven 依赖）

## 快速开始

### 1. 克隆模板

```bash
git clone <仓库地址>
cd PickAIDForgeTemplate-26.1
```

### 2. 编辑 `project.toml`

新项目最少先改这两块：

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

如果要做测试版或热修：

```toml
version = "1.2.0"
version_suffix = "hotfix.1"
```

最终版本会变成 `1.2.0-hotfix.1`。

### 3. 替换占位代码

通常先看这几个位置：

1. `src/main/java/org/pickaid/example/Example.java`
2. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
3. `src/scaffolds/modern-neoforge/templates/META-INF/neoforge.mods.toml`
4. `src/templates/mixins.json`

如果你的项目不用 Mixin，就删除示例 Mixin 和 `src/templates/mixins.json`。

### 4. 导入 Gradle 并构建一次

```bash
./gradlew help
./gradlew build
```

这条分支使用 `ModDevGradle`，不再走 `genIntellijRuns`。把 Gradle 项目导入 IDE 并同步即可。

### 5. （可选）创建 `project.local.toml`

从示例文件复制一份，存放本机私有配置：

```bash
cp project.local.toml.example project.local.toml
```

适合放进去的内容：

- `[run].mc_user`
- `[publish].maven_user` / `maven_password`
- `[publish].modrinth_token` / `curseforge_token`

## 配置参考

### `[mod]` — 模组身份

每个新项目最先修改的块。

| 字段 | 说明 |
|---|---|
| `mod_id` | NeoForge 模组 ID |
| `mod_name` | 面向玩家的显示名称 |
| `version` | 基础版本号 |
| `version_suffix` | 可选版本后缀 |
| `group` | Maven group |
| `authors` | 作者列表 |
| `license` | 许可证标识 |
| `description` | 模组描述 |
| `credits` | 致谢信息（可选） |
| `issue_tracker_url` | Issue 地址（可选） |

### `[features]` — 生态集成开关

当前分支已经校准：

- `jei`
- `curios`
- `mixin_extras`

`geckolib` 和 `player_animator` 先保留为关闭状态；在它们发布可用的 `26.1.2` 构件前，开启会被配置校验拒绝。

没用到就保持 `false`。

### `[overrides]` — 版本覆盖

只有当你开启了某个 feature，但又不想使用模板默认版本时才需要改。

当前可用：

- `jei_version`
- `curios_version`
- `mixin_extras_version`

### `[dev_packs]` — 本地调试辅助包

这条分支目前只保留已经重新校准过的本地辅助包。

当前支持：

- `basic`: JEI + Jade
- `appleskin`: AppleSkin
- `curios`: Curios

它只影响本地运行环境，不定义你的正式 API 面。

### `[repositories]` — 额外 Maven 仓库

常见生态仓库已经在模板里准备好了。只有当你要拉的依赖不在这些仓库里时，才需要继续追加：

```toml
[repositories]
custom_repo = "https://maven.example.com/releases"
```

也支持 inline table：

```toml
[repositories]
custom_repo = { url = "https://maven.example.com/releases", name = "Example", groups = ["com.example"] }
```

### `[dependencies.*]` / `[embedded_projects.*]` — 额外依赖与嵌入子项目

大多数额外依赖都写在这里，而不是继续改 `build.gradle`。

常见依赖桶：

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

Gradle 子项目不放在 `[dependencies.*]`，而是放在：

- `[embedded_projects.api]`
- `[embedded_projects.implementation]`

`jarjar` 和 `embedded_projects.*` 最容易混，直接记这三句：

- `jarjar` 决定“外部依赖要不要打进最终 jar”
- `embedded_projects.*` 决定“Gradle 子项目要不要被主模组一起带上”
- `api` / `compile_only_api` 决定“下游编译时能不能看到它”

### `[metadata]` — 模组展示信息

这一段会写进 `neoforge.mods.toml`。

当前模板开放的字段有：

- `logo_file`
- `logo_blur`
- `show_as_resource_pack`
- `show_as_data_pack`
- `update_json_url`
- `display_url`
- `display_test`，允许 `MATCH_VERSION`、`IGNORE_SERVER_VERSION`、`IGNORE_ALL_VERSION`、`NONE`

### `[mod_relations.*]` — 模组关系声明

这条分支可以直接表达这些关系类型：

- `required`
- `optional`
- `incompatible`
- `discouraged`
- `embedded`

最短字符串写法表示只写 `version_range`：

```toml
[mod_relations.required]
curios = "[15.0.0-beta.2,)"
```

除了 `embedded` 以外，这条分支上的关系都必须提供 `version_range`。如果使用 inline table，`ordering` 只能是 `NONE`、`BEFORE`、`AFTER`，`side` 只能是 `BOTH`、`CLIENT`、`SERVER`。

完整写法可以继续带这些字段：

- `mod_id`
- `version_range`
- `ordering`
- `side`
- `reason`
- `referral_url`
- `modrinth`
- `curseforge`

例如：

```toml
[mod_relations.optional]
jade = { version_range = "*", modrinth = "nvQzSEkH", curseforge = "324717" }

[mod_relations.incompatible]
old_renderer = { version_range = "*", reason = "Hooks the same render pipeline" }
```

`embedded` 不写入 `neoforge.mods.toml`，只用于上传平台关系，所以至少要填一个 `modrinth` 或 `curseforge` 项目 ID。

### `[publish]` — 发布配置

这里控制：

- `maven_url`
- `curseforge_project`
- `modrinth_project`
- `release_type`

敏感信息优先放环境变量，或者放到 `project.local.toml`。

常用环境变量：

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

### `[naming]` — 产物命名

控制最终 jar 文件名。

支持的 token：

- `{archive_name}`
- `{mod_id}`
- `{version}`
- `{mc_version}`
- `{loader}`

默认写法：

```toml
jar_format = "{archive_name}-{mc_version}-{version}"
```

## 目录结构

### `project.toml`

主配置入口。这里放模组信息、依赖、发布配置和产物命名。

### `project.local.toml`

本机私有配置，不进 git。

### `src/main/java`

主源码目录。示例入口和示例 Mixin 都在这里。

### `src/scaffolds/modern-neoforge/templates`

`neoforge.mods.toml` 的模板来源。只有你要改生成出来的元数据结构时才需要碰。

### `src/templates/mixins.json`

共享的 Mixin 配置模板。

## 发布指南

### 发布到本地 Maven

```bash
./gradlew publishToMavenLocal
```

### 发布到远程 Maven

```bash
./gradlew publish
```

前提是已经配置好 `publish.maven_url` 或 `MAVEN_URL`，以及对应认证。

### 上传到 Modrinth / CurseForge

```bash
./gradlew buildAndUploadMod
```

前提是：

- `project.toml` 里已经填对应项目 ID
- 环境变量或本机私有 TOML 中已经提供 token

## 产物说明

当前这条分支的 Maven 发布重点是：

- 主 jar
- `sources` jar
- `javadoc` jar

另外会生成一个 `deobf` 辅助 jar 供开发使用。

平台上传使用的是主 jar。

## 下游模组如何依赖

普通下游一般这样写：

```gradle
repositories {
    maven { url = "https://your-maven.example/releases" }
}

dependencies {
    implementation "com.yourname.yourmod:yourmod:1.0.0"
}
```

如果你自己的源码还直接 import 了对方公开暴露的 JEI / Curios 等 API，仍然要在自己的工程里显式声明这些 API 依赖。

## Gradle 镜像

仓库里建议保持官方 Gradle Wrapper 地址。

如果你本地下载慢，可以只在自己机器上切换镜像，再在提交前切回官方地址。

## 常用命令

```bash
./gradlew build
./gradlew runClient
./gradlew runServer
./gradlew runData
./gradlew publishToMavenLocal
./gradlew publish
./gradlew buildAndUploadMod
```

## 常见问题

### 为什么这条分支不用 `genIntellijRuns`？

因为它已经切到了官方 `ModDevGradle` 流程。IDE 直接导入 Gradle 项目并同步即可。

### `embedded_projects.*` 和 `mod_relations.embedded` 有什么区别？

不是一回事：

- `embedded_projects.*` 是“把 Gradle 子项目打进主模组”
- `mod_relations.embedded` 是“给 Modrinth / CurseForge 标记 embedded library 关系”

### 想限制某个依赖模组的版本范围怎么写？

用 `mod_relations.*` 里的 `version_range`：

```toml
[mod_relations.required]
curios = "[15.0.0-beta.2,16.0.0)"
```
