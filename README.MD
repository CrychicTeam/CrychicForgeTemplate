<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft Forge Mod 开发模板

[English Version](README_EN.md) | 中文版

这是一个给 Minecraft `1.20.1` Forge 用的模组模板。

它的核心目标很简单：

- 你主要改 `project.toml`
- 你把模板里的占位包名和资源路径换成自己的
- 然后直接开始写模组

而不是每开一个新项目，都先花一轮时间重新整理 Gradle、发布、运行配置和依赖。

如果你是第一次用这个模板，可以先记住一句话：

> 先改 `project.toml` 里的模组信息，再把 `modid` 占位路径改掉，然后跑一次 `./gradlew build`。

## 这个模板已经帮你准备了什么

- 可直接启动的 Forge 1.20.1 项目骨架
- `project.toml` 驱动的项目配置
- 常见模组生态的 feature 开关
- 本地开发用的 dev pack 开关
- Maven 发布，包含 `sources`、`javadoc`、`runtime` jar
- Modrinth 和 CurseForge 上传链路
- 通过 TOML 加仓库和依赖，而不是反复手改 `build.gradle`

老的 `template.toml` 和 `build.txt` 已经彻底废弃。

现在模板固定读取：

- `project.toml`
- 可选的 `project.local.toml`

## 最短上手路径

### 1. 克隆模板

```bash
git clone [仓库地址]
cd PickAIDForgeTemplate
```

### 2. 先改 `project.toml`

第一次只需要把最关键的几项改掉：

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

如果你现在不关心发布，那 `[publish]` 保持默认就行。

`version_suffix` 也可以先留空。
如果以后你想做热修或测试版，可以写成这样：

```toml
version = "1.2.0"
version_suffix = "hotfix.1"
```

最后版本号会变成 `1.2.0-hotfix.1`。

### 3. 把模板里的占位路径换掉

正式开始写逻辑前，先把这些占位内容改成你自己的：

1. `src/main/java/org/pickaid/modid/`
2. `src/main/resources/assets/modid/`
3. `src/main/resources/mixins.modid.json`
4. `src/main/java/org/pickaid/modid/Example.java`

### 4. 先构建一次

```bash
./gradlew genIntellijRuns
./gradlew build
```

只要这一步能过，说明模板已经基本切到你的项目名下了。

### 5. 可选：写一个 `project.local.toml`

这个文件默认不进 git，适合放只属于你本机的配置，比如：

- `mc_user`
- 本机临时发布凭证
- 本机联调用的小开关

可以直接从 [`project.local.toml.example`](/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate/project.local.toml.example) 复制。

## `project.toml` 怎么看

如果你是第一次用这种配置方式，可以把它理解成：

- `[mod]` 是“我这个模组是谁”
- `[features]` 是“我要不要接常见生态”
- `[dev_packs]` 是“我本地调试时想不想顺手带上一组辅助模组”
- `[repositories]` 是“我还需要去哪找额外依赖”
- `[dependencies.*]` 是“我还要不要额外加别的依赖”
- `[publish]` 是“我要怎么发版”
- `[naming]` 是“最终产物叫什么”

下面按实际使用顺序来讲。

### `[mod]`

这是最重要的一段。你每次新建项目，最先改的就是这里。

- `mod_id`：Forge mod id，尽量全小写
- `mod_name`：显示给玩家看的名字
- `version`：基础版本号
- `version_suffix`：可选后缀，比如 `beta.2`、`hotfix.1`
- `group`：Maven group
- `authors`：作者列表，不能为空
- `license`：许可证
- `description`：会写进 `mods.toml`

如果你不知道先填什么，先把 `mod_id`、`mod_name`、`group`、`version` 填对，其他先用普通值也行。

### `[features]`

这是模板已经直接支持的常见生态开关。

当前支持：

- `jei`
- `curios`
- `geckolib`
- `player_animator`
- `mixin_extras`

你可以把它理解成“我想不想让模板替我把这一类常见集成接上”。

例如：

- 想在代码里直接使用 JEI API，就开 `jei = true`
- 想接 Curios，就开 `curios = true`
- 想做 GeckoLib 动画，就开 `geckolib = true`

没用到就关着，保持最小依赖面。

### `[overrides]`

大多数项目一开始不用动这里。

它的作用不是“常规配置”，而是：

> 当你已经开了某个 feature，但你明确想换掉模板给的默认版本时，再来这里改。

现在支持：

- `jei_version`
- `curios_version`
- `geckolib_version`
- `player_animator_version`
- `bendylib_version`
- `mixin_extras_version`

如果你没有明确版本需求，就让它空着，最省事。

### `[dev_packs]`

这是给本地开发准备的辅助模组包。

它们的作用不是定义你正式发布的 API 面，而是让你调试更顺手。

当前内置：

- `basic`：JEI + Jade
- `appleskin`：AppleSkin
- `combat`：Target Dummy + AttributeFix + Max Health Fix
- `curios`：Curios 本地运行环境
- `spell`：Caelus + Iron's Spellbooks
- `kubejs`：Architectury + Rhino + KubeJS 本地脚本环境

例如你想本地调试时顺手看配方、看方块/实体信息，可以直接开：

```toml
[dev_packs]
basic = true
combat = false
```

如果你只是想让本地运行更方便，用 `dev_packs`。
如果你要在源码里直接 import 某个模组的 API，用 `[features]` 或 `[dependencies.*]`。

### `[repositories]`

这里现在已经预填好了常见生态仓库。

也就是说，大多数项目你根本不用碰它。

现在这几个地址已经在 `project.toml` 里了：

- BlameJared
- tterrag
- Sponge
- GeckoLib
- Curios
- KosmX
- CurseMaven
- Architectury
- Latvian / KubeJS
- JitPack

你只在一种情况下需要继续改这里：

> 你要加的那个库或模组，不在这些常见仓库里。

那就自己补一条：

```toml
[repositories]
redspace = "https://code.redspace.io/releases"
```

或者用更完整的写法：

```toml
[repositories]
redspace = { url = "https://code.redspace.io/releases", name = "Redspace", groups = ["io.redspace.ironsspellbooks"] }
```

### `[dependencies.*]`

这是通用依赖层。

你可以把它理解成：

> feature 不够用时，用这里；你要加自己项目特有的依赖时，也用这里。

支持的 bucket 有这些：

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

如果你现在看这些名字有点乱，只先记住最常用的四个：

- `deobf_api`：你暴露给下游的 mod API 依赖
- `deobf_implementation`：你自己内部要用的 mod 依赖
- `deobf_compile_only`：只需要编译时可见的 mod 依赖
- `deobf_runtime_only`：只需要本地运行时带上的 mod 依赖

再简单一点：

- 想让下游也看见：`api`
- 只想自己用：`implementation`
- 只是编译要用：`compile_only`
- 只是运行要用：`runtime_only`

前面带 `deobf_` 的，就是给 mod 依赖准备的。

这里我已经把一些常见写法作为注释示例放进 `project.toml` 了，比如：

- Registrate
- JEI API / 运行时
- Curios
- GeckoLib
- Player Animator
- MixinExtras
- KubeJS / Rhino
- Architectury

这些默认都是注释状态，目的是让你以后需要时可以直接抄，不用再回头找坐标。

如果你已经通过 `[features]` 开了某个集成，通常就不要再在 `[dependencies.*]` 里手工重复声明同一份依赖。

### `[publish]`

这里管的是发版。

- `maven_url`：你的 Maven 仓库地址
- `curseforge_project`：CurseForge 项目 id，`0` 表示关闭
- `modrinth_project`：Modrinth 项目 id，空字符串表示关闭
- `release_type`：`alpha`、`beta`、`release`

如果你只是本地开发，不急着发版，保持默认就行。

敏感信息建议放环境变量，或者放进本机用的 `project.local.toml`。

常用环境变量：

- `MAVEN_URL`
- `MAVEN_USER`
- `MAVEN_PASSWORD`
- `MODRINTH_TOKEN`
- `CURSEFORGE_TOKEN`

`project.local.toml` 里可以这样写：

```toml
[publish]
maven_user = "your-user"
maven_password = "your-password"
modrinth_token = "your-modrinth-token"
curseforge_token = "your-curseforge-token"

[run]
mc_user = "DevPlayer,00000000000000000000000000000001"
```

之所以不建议把这些写进 `project.toml`，原因很现实：

- 它们是你的机器配置，不是项目公共配置
- 它们会让仓库反复变脏
- 它们不适合进入 git 历史

### `[naming]`

这里只有两件事：

- `archive_name`：产物基础名
- `jar_format`：最终 jar 文件名格式

支持的 token：

- `{archive_name}`
- `{mod_id}`
- `{version}`
- `{mc_version}`
- `{loader}`

默认够用的格式是：

```toml
jar_format = "{archive_name}-{mc_version}-{version}"
```

## 发版相关

### 发布到本地 Maven

```bash
./gradlew publishToMavenLocal
```

### 发布到自己的 Maven

1. 在 `project.toml` 里填 `publish.maven_url`，或者直接设置 `MAVEN_URL`
2. 如果仓库需要认证，再设置 `MAVEN_USER` 和 `MAVEN_PASSWORD`
3. 运行：

```bash
./gradlew publish
```

### 上传到 Modrinth / CurseForge

1. 在 `project.toml` 里填对应项目 id
2. 设置对应 token
3. 运行：

```bash
./gradlew buildAndUploadMod
```

这里上传的是 `runtime` jar，不是开发 jar。

## 这个模板会发布哪些产物

Maven 发布默认会带上：

- 开发 jar
- `runtime` jar
- `sources` jar
- `javadoc` jar

实际理解可以直接记这一句：

- 下游编译时，通常吃默认 artifact
- 平台上传时，发的是 `runtime` artifact

## 下游模组怎么依赖你

如果你把这个模板产出的模组发到了 Maven，下游一般这样写：

```gradle
repositories {
    maven { url = "https://your-maven.example/releases" }
}

dependencies {
    implementation "com.yourname.yourmod:yourmod:1.0.0"
}
```

这里通常不需要再包一层 `fg.deobf(...)`。

如果你明确要用打包后的运行时产物，再单独写：

```gradle
runtimeOnly "com.yourname.yourmod:yourmod:1.0.0:runtime"
```

## Gradle 下载镜像

默认仓库保留官方 Wrapper 地址：

- `https://services.gradle.org`

如果你在中国大陆，下载慢是正常情况。

模板里带了一个切换脚本：

```bash
bash tools/set-gradle-wrapper-mirror.sh official
bash tools/set-gradle-wrapper-mirror.sh aliyun
bash tools/set-gradle-wrapper-mirror.sh huawei
```

可选预设：

- `official`
- `aliyun`
- `huawei`

比较稳妥的做法是：

- 本地慢，就先切镜像
- 准备提交时，再切回 `official`

## 常用命令

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

## 常见问题

### 我只是想开始写模组，最少到底要改什么

先改这三类就够了：

1. `project.toml` 里的 `[mod]`
2. `org/pickaid/modid` 相关 Java 包路径
3. `assets/modid` 和 `mixins.modid.json`

然后跑一次：

```bash
./gradlew build
```

### 我什么时候该用 `features`，什么时候该用 `dependencies`

简单记：

- 模板已经支持的常见生态，用 `features`
- 只是本地调试图省事，用 `dev_packs`
- 自己额外要加的东西，用 `[dependencies.*]`

### 现在怎么加 KubeJS

KubeJS 现在更适合走通用依赖层，或者直接开本地 dev pack。

如果你只是想本地跑一下脚本环境：

```toml
[dev_packs]
kubejs = true
```

如果你要显式声明依赖，可以用：

```toml
[dependencies.deobf_compile_only]
kubejs = "dev.latvian.mods:kubejs-forge:2001.6.4-build.120"
rhino = "dev.latvian.mods:rhino-forge:2001.2.2-build.18"

[dependencies.deobf_implementation]
architectury = { notation = "dev.architectury:architectury-forge:9.1.12", transitive = false }
```

### 为什么 `build.txt` 或 `template.toml` 会直接报错

这是故意的。

模板不允许新旧配置混用。发现旧文件就直接失败，目的是让配置面保持单一，不让项目以后变成“有一半在新配置里，有一半在旧配置里”。

### 什么时候需要写 `fg.deobf(...)`

通过 `project.toml` 加 mod 依赖时，`deobf_*` 这些 bucket 已经帮你处理了。

反过来，消费这个模板发布出来的模组时，通常直接写普通 Maven 坐标就够了。
