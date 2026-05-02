<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate — NeoForge 26.1.2 模组模板

[English Version](README_EN.md) | 中文版

`PickAIDForgeTemplate-26.1` 是面向 `Minecraft 26.1.2` / `NeoForge 26.1.2.x` 的模板分支。它用 `project.toml` 作为单一配置入口，把**模组信息、依赖、运行配置和发布链路**放在一套固定结构里，避免每个新项目都重新整理 Gradle。

## 目录

- [模板预置内容](#模板预置内容)
- [前置条件](#前置条件)
- [快速开始](#快速开始)
- [配置参考](#配置参考)
  - [[mod] — 模组身份](#mod--模组身份)
  - [[features] — 生态集成开关](#features--生态集成开关)
  - [[languages] — Java/Kotlin 开关](#languages--javakotlin-开关)
  - [[overrides] — 版本覆盖](#overrides--版本覆盖)
  - [[dev_packs] — 本地调试辅助包](#dev_packs--本地调试辅助包)
  - [[repositories] — 额外 Maven 仓库](#repositories--额外-maven-仓库)
  - [[dependencies.*] / [embedded_projects.*] — 额外依赖与嵌入子项目](#dependencies--embedded_projects--额外依赖与嵌入子项目)
  - [[native_libraries.*] — 预编译 Native 库](#native_libraries--预编译-native-库)
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

- **NeoForge 26.1.2 项目骨架**：基于官方 `ModDevGradle`
- **`project.toml` 配置驱动**：模组信息、依赖、发布走一套 TOML 结构
- **生态集成开关**：当前已校准 JEI、Curios、MixinExtras
- **语言支持**：Java 默认启用，Kotlin 可选启用并与 Java 混写
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
3. `src/templates/META-INF/neoforge.mods.toml`
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

### `[languages]` — Java/Kotlin 开关

Java 是默认路径，始终启用。Kotlin 是可选增强，开启后可以把源码放在 `src/main/kotlin`，并继续和 `src/main/java` 混写：

```toml
[languages]
kotlin = true
```

优先级建议保持为：Java > Kotlin > native。也就是说，普通 NeoForge API 和大多数依赖优先走 Java；需要 Kotlin 语法或库生态时再开启 Kotlin；Rust/C/C++ 这类 native 库只作为高级场景使用。

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

### `[native_libraries.*]` — 预编译 Native 库

这是高级功能，用来打包已经编译好的 JNI/JNA 二进制，不负责从 Rust/C/C++ 源码构建。每个库声明一个子表：

```toml
[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["windows-x86_64", "linux-x86_64", "macos-aarch64"]
required = true
```

文件布局必须和平台匹配：

```text
native-libs/
  physics/
    windows-x86_64/pickaid_physics.dll
    linux-x86_64/libpickaid_physics.so
    macos-aarch64/libpickaid_physics.dylib
```

构建时模板会把文件打进 jar，并生成 `NativeLibraries` Java helper。运行时可从 `${group}.${mod_id}.runtime.NativeLibraries` 调用 `load("physics")`；如果使用 JNA，也可以使用返回的 `Path` 交给 JNA 绑定。

#### JNI：从 Java/Kotlin 调用自己写的 native 方法

假设：

```toml
[mod]
mod_id = "physicsmod"
group = "com.example"

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["macos-aarch64", "linux-x86_64", "windows-x86_64"]
required = true
```

生成的 helper 包名是 `com.example.physicsmod.runtime.NativeLibraries`。Java 侧先加载库，再声明 `native` 方法：

```java
package com.example.physicsmod.physics;

import com.example.physicsmod.runtime.NativeLibraries;

public final class PhysicsNative {
    static {
        NativeLibraries.load("physics");
    }

    private PhysicsNative() {
    }

    public static native int add(int left, int right);
}
```

Kotlin 代码可以直接调用这个 Java wrapper：

```kotlin
val result = PhysicsNative.add(20, 22)
```

C 侧函数名必须匹配 Java 包名、类名和方法名：

```c
#include <jni.h>

JNIEXPORT jint JNICALL Java_com_example_physicsmod_physics_PhysicsNative_add(
    JNIEnv *env,
    jclass type,
    jint left,
    jint right
) {
    return left + right;
}
```

编译输出文件必须放进模板约定的目录。macOS aarch64 示例：

```bash
mkdir -p native-libs/physics/macos-aarch64
clang -dynamiclib \
  -I"$JAVA_HOME/include" \
  -I"$JAVA_HOME/include/darwin" \
  physics.c \
  -o native-libs/physics/macos-aarch64/libpickaid_physics.dylib
```

Linux x86_64 示例：

```bash
mkdir -p native-libs/physics/linux-x86_64
clang -shared -fPIC \
  -I"$JAVA_HOME/include" \
  -I"$JAVA_HOME/include/linux" \
  physics.c \
  -o native-libs/physics/linux-x86_64/libpickaid_physics.so
```

Windows 输出文件名应为 `native-libs/physics/windows-x86_64/pickaid_physics.dll`。

#### JNA：绑定已有 C ABI 库

如果 native 库已经导出了普通 C 函数，而你不想写 JNI glue code，可以使用 JNA。先把 JNA 打进 jar：

```toml
[dependencies.jarjar]
jna = { notation = "net.java.dev.jna:jna:5.14.0", range = "[5.14.0,)" }

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jna"
platforms = ["macos-aarch64", "linux-x86_64", "windows-x86_64"]
required = true
```

Java 绑定示例：

```java
package com.example.physicsmod.physics;

import com.example.physicsmod.runtime.NativeLibraries;
import com.sun.jna.Library;
import com.sun.jna.Native;

public interface PhysicsLibrary extends Library {
    PhysicsLibrary INSTANCE = Native.load(
        NativeLibraries.load("physics").toString(),
        PhysicsLibrary.class
    );

    int add(int left, int right);
}
```

Kotlin 调用同一个 JNA binding：

```kotlin
val result = PhysicsLibrary.INSTANCE.add(20, 22)
```

对应的 C 库只需要导出普通函数：

```c
int add(int left, int right) {
    return left + right;
}
```

选择建议：JNI 更适合性能敏感或需要 JVM 交互的桥接层；JNA 更适合直接接入已有 C ABI 库。

### 使用组合

#### Java only（默认）

不需要额外配置，保持：

```toml
[languages]
kotlin = false
```

代码放在 `src/main/java`，普通 Java/NeoForge 开发都走这条路径。

#### Kotlin only（仍保留 Java 工具链）

开启 Kotlin，把业务代码放在 `src/main/kotlin`。Gradle 仍然保留 Java source set，因为 NeoForge、注解处理和生成代码依旧依赖 Java 工具链。

```toml
[languages]
kotlin = true
```

#### Java + Kotlin

开启 Kotlin 后，`src/main/java` 和 `src/main/kotlin` 会一起编译。Java 可以调用 Kotlin 暴露的 `@JvmStatic` / 普通 JVM API，Kotlin 也可以直接调用 Java 类。

```toml
[languages]
kotlin = true
```

#### Java + native

保持 Kotlin 关闭，只声明 native 库。Java 代码中调用生成的 helper：

```toml
[languages]
kotlin = false

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["windows-x86_64", "linux-x86_64", "macos-aarch64"]
required = true
```

```java
NativeLibraries.load("physics");
```

#### Java + Kotlin + native

同时开启 Kotlin 和 native。Java/Kotlin 都可以调用生成的 `NativeLibraries` helper：

```toml
[languages]
kotlin = true

[native_libraries.physics]
load_name = "pickaid_physics"
loader = "jni"
platforms = ["windows-x86_64", "linux-x86_64", "macos-aarch64"]
required = true
```

```kotlin
NativeLibraries.load("physics")
```

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

### `src/templates/META-INF`

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
