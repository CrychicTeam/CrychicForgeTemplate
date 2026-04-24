<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft NeoForge 1.21.1 模组模板

[English Version](README_EN.md) | 中文版

这条分支只负责 `NeoForge 1.21.1`。

如果你要做别的 Minecraft 版本，直接切到对应分支，不在 `project.toml` 里选 profile，也不在 Gradle 参数里传 `templateProfile`。

这套模板现在的目标很简单：

- 主配置只改 `project.toml`
- 构建和运行用官方 `ModDevGradle`
- 不再维护旧的 `build.txt`
- 依赖、Mixin 和发布配置尽量数据化

## 最短上手路径

### 1. 先改 `project.toml`

第一次通常只需要先改这些：

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

### 2. 把示例内容换成你自己的

最先要看的几个位置：

1. `src/main/java/org/pickaid/example/Example.java`
2. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
3. `src/scaffolds/modern-neoforge/templates/META-INF/neoforge.mods.toml`
4. `src/templates/mixins.json`

如果你不用 Mixin，就把示例 Mixin 删掉，同时把 `src/templates/mixins.json` 一起清掉。

### 3. 导入 Gradle 项目并跑一次构建

```bash
./gradlew help
./gradlew build
```

这支是 `ModDevGradle` 模板，不再走 `genIntellijRuns` 那套旧流程。导入 Gradle 项目后直接让 IDE 同步即可。

## 常用命令

```bash
./gradlew runClient
./gradlew runServer
./gradlew runData
./gradlew publishToMavenLocal
```

## 你会经常改到的地方

### `project.toml`

主配置入口。这里负责：

- 模组基本信息
- feature 开关
- 当前分支已经校准好的 dev pack
- 额外仓库
- 额外依赖
- 发布配置
- 产物命名

### `project.local.toml`

本机私有配置，不进 git。适合放：

- `mc_user`
- 临时 Maven 用户名和密码
- Modrinth / CurseForge token

可以直接从 [`project.local.toml.example`](project.local.toml.example) 复制。

### `src/main/java`

标准 Java 源码目录。示例入口和示例 Mixin 都在这里。

### `src/scaffolds/modern-neoforge/templates`

分支自己的 `neoforge.mods.toml` 模板。构建时会展开成真正的元数据文件。

### `src/templates/mixins.json`

共享的 Mixin 配置模板。构建时会生成 `${mod_id}.mixins.json`。

## 这条分支现在的范围

这条分支已经明确收束为 `NeoForge 1.21.1 + ModDevGradle`。

- 不接受 `[platform]`
- 不接受 `-PtemplateProfile=...`
- 不再兼容 `build.txt`

如果你需要别的 Minecraft 版本，就切到对应版本分支。
