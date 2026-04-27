<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate — Minecraft Mod 开发模板

[English Version](README_EN.md) | 中文版

PickAIDForgeTemplate 是一个以 `project.toml` 为单一配置入口的 Minecraft Forge 模组开发模板。用一套结构管理**模组信息、依赖、功能开关、运行配置和发布链路**，避免每个新项目都从零整理 Gradle。

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
    - [[dependencies.\*] — 额外依赖](#dependencies--额外依赖)
    - [[native_libraries.\*] — 预编译 Native 库](#native_libraries--预编译-native-库)
    - [[metadata] — 模组展示信息](#metadata--模组展示信息)
    - [[mod_relations.\*] — 模组关系声明](#mod_relations--模组关系声明)
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

克隆模板后，以下内容已经就绪：

- **Forge 项目骨架**：可直接 `./gradlew build` 通过
- **`project.toml` 配置驱动**：模组信息、依赖、发布全部走 TOML
- **生态集成开关**：JEI、Curios、GeckoLib、Player Animator、MixinExtras 一键启停
- **语言支持**：Java 默认启用，Kotlin 可选启用并与 Java 混写
- **本地开发辅助包**：预配好的开发环境模组组合（JEI + Jade、AppleSkin、战斗调试等）
- **Maven 发布**：输出 development、runtime、sources、javadoc 四个 jar
- **Modrinth / CurseForge 上传**：内置上传任务，token 通过环境变量注入
- **TOML 依赖管理**：新增依赖和仓库在 `project.toml` 中声明，无需修改 `build.gradle`

> 旧的 `template.toml` 和 `build.txt` 已废弃。模板只读取 `project.toml` 和可选的 `project.local.toml`。

## 前置条件

- **JDK 17** 或更高版本
- 一个可用的 Gradle 环境（项目自带 Gradle Wrapper，无需额外安装）
- 基本的 Minecraft Mod 开发概念（了解 `mod_id`、`mods.toml`、Mixin 等术语）

## 快速开始

### 1. 克隆模板

```bash
git clone <仓库地址>
cd PickAIDForgeTemplate
```

### 2. 编辑 `project.toml`

最少需要修改 `[mod]` 和 `[naming]` 两个块：

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

`version_suffix` 是可选的。当需要热修复或测试版时再填写：

```toml
version = "1.2.0"
version_suffix = "hotfix.1"   # 最终版本号 → 1.2.0-hotfix.1
```

如果暂时不关心发布，`[publish]` 保持默认值即可。

### 3. 替换占位代码

将以下模板占位文件中的包名和类名改为你自己的：

1. `src/scaffolds/legacy-forge/java/org/pickaid/example/Example.java`
2. `src/main/java/org/pickaid/example/mixins/ExampleMixin.java`
3. `src/templates/mixins.json`

如果你的项目不使用 Mixin，删除示例 Mixin 类和 `src/templates/mixins.json` 即可。

### 4. 构建验证

```bash
./gradlew genIntellijRuns
./gradlew build
```

构建通过说明模板已成功切换到你的项目名下。

### 5. （可选）创建 `project.local.toml`

从示例文件复制一份，用于存放本机私有配置（此文件在 `.gitignore` 中，不会进入版本控制）：

```bash
cp project.local.toml.example project.local.toml
```

适合写入的内容：

- `[run].mc_user`：本地调试用的 Minecraft 用户名和 UUID
- `[publish].maven_user` / `maven_password`：本机 Maven 发布凭证
- `[publish].modrinth_token` / `curseforge_token`：平台上传 token

## 我现在该改哪一块

第一次用模板时，通常只会遇到下面几种情况：

- **我只想把模板改成自己的模组**：改 `[mod]` 和 `[naming]`
- **我只想本地跑起来看配方、HUD、战斗数据**：改 `[dev_packs]`
- **我需要在源码里直接 import 某个模组 API**：优先改 `[features]`，或在 `[dependencies.deobf_*]` 里手动声明
- **我想用 Kotlin 写一部分代码**：改 `[languages].kotlin`
- **我只是想加一个普通 Java 库**：改 `[dependencies.implementation]`、`[dependencies.api]`、`[dependencies.compile_only]` 这些基础桶
- **我想把额外库一起打进最终 jar**：改 `[dependencies.jarjar]`
- **我想带上 Rust/C/C++ 编译好的 JNI/JNA 库**：改 `[native_libraries.*]`，并把二进制放进 `native-libs/`
- **我想声明依赖/冲突/可选联动并写进 `mods.toml`**：改 `[mod_relations.*]`
- **我想发到 Maven、Modrinth、CurseForge**：改 `[publish]`

## 配置参考

以下是 `project.toml` 中各配置块的完整说明，按实际使用频率排列。

### `[mod]` — 模组身份

每个新项目最先修改的块，定义模组的基本身份信息。

| 字段                | 说明                              |
| ------------------- | --------------------------------- |
| `mod_id`            | Forge 模组 ID，建议全小写         |
| `mod_name`          | 面向玩家展示的名称                |
| `version`           | 基础版本号，遵循 SemVer           |
| `version_suffix`    | 可选后缀，如 `beta.2`、`hotfix.1` |
| `group`             | Maven group，对应 Java 包名       |
| `authors`           | 作者列表，不能为空                |
| `license`           | 许可证标识（写入 `mods.toml`）    |
| `description`       | 模组描述（写入 `mods.toml`）      |
| `credits`           | 致谢信息（可选）                  |
| `issue_tracker_url` | Issue 跟踪地址（可选）            |

### `[features]` — 生态集成开关

模板内置的常见模组生态集成。开启后，模板会自动配置对应的编译依赖、Mixin 配置和运行时依赖。

| 开关              | 对应集成               |
| ----------------- | ---------------------- |
| `jei`             | Just Enough Items API  |
| `curios`          | Curios API             |
| `geckolib`        | GeckoLib 动画引擎      |
| `player_animator` | Player Animator 动画库 |
| `mixin_extras`    | MixinExtras 增强 Mixin |

```toml
[features]
jei = false
curios = false
geckolib = false
player_animator = false
mixin_extras = true
```

不需要的集成保持 `false` 即可，保持最小依赖面。

### `[languages]` — Java/Kotlin 开关

Java 是默认路径，始终启用。Kotlin 是可选增强，开启后可以把源码放在 `src/main/kotlin`，并继续和 `src/main/java` 混写：

```toml
[languages]
kotlin = true
```

优先级建议保持为：Java > Kotlin > native。也就是说，普通 Forge API 和大多数依赖优先走 Java；需要 Kotlin 语法或库生态时再开启 Kotlin；Rust/C/C++ 这类 native 库只作为高级场景使用。

### `[overrides]` — 版本覆盖

当你使用了某个 feature 但需要不同于模板默认的版本时使用。**大多数项目不需要修改此块。**

| 键                        | 对应 feature      |
| ------------------------- | ----------------- |
| `jei_version`             | `jei`             |
| `curios_version`          | `curios`          |
| `geckolib_version`        | `geckolib`        |
| `player_animator_version` | `player_animator` |
| `bendylib_version`        | `player_animator` |
| `mixin_extras_version`    | `mixin_extras`    |

仅在对应 feature 启用时生效。没有明确的版本需求时保持留空即可。

### `[dev_packs]` — 本地调试辅助包

影响的是**本地开发运行环境**，不定义正式发布的 API 依赖面。目的是让本地调试更顺手——查配方、看 HUD、测战斗平衡等。

| 包名        | 包含内容                                     | 用途                    |
| ----------- | -------------------------------------------- | ----------------------- |
| `basic`     | JEI + Jade                                   | 配方查看、方块/实体信息 |
| `appleskin` | AppleSkin                                    | 饥饿值和饱和度 HUD      |
| `combat`    | Target Dummy + AttributeFix + Max Health Fix | 战斗数值调试            |
| `curios`    | Curios                                       | 饰品槽位本地测试        |
| `spell`     | Caelus + Iron's Spellbooks                   | 法术/属性烟雾测试       |

```toml
[dev_packs]
basic = true
combat = false
```

**注意区分使用场景**：

- `dev_packs` → 只为本地运行时带上辅助模组，不影响编译
- `features` → 同时配置编译依赖和运行时依赖，可在源码中 import 对应 API
- `[dependencies.*]` → 手动声明任意额外依赖

`1.20.1` 这条主线里，KubeJS 不再作为内置 `dev_pack` 维护；需要时直接按普通依赖手动加。

### `[repositories]` — 额外 Maven 仓库

模板已预填以下常用仓库，覆盖了 Registrate、JEI、Curios、GeckoLib、MixinExtras、Architectury、KubeJS 等主流生态：

- BlameJared、tterrag、Sponge、GeckoLib、Curios、KosmX、CurseMaven、Architectury、Latvian、JitPack

**大多数项目无需修改此块。** 只有当你要添加的依赖不在上述仓库中时，才需要追加：

```toml
[repositories]
redspace = "https://code.redspace.io/releases"
```

需要更精确的控制时（如限定 group 过滤），使用 inline table 写法：

```toml
[repositories]
redspace = { url = "https://code.redspace.io/releases", name = "Redspace", groups = ["io.redspace.ironsspellbooks"] }
```

### `[dependencies.*]` — 额外依赖

这是 "额外依赖声明区"。大多数项目只需要修改这里，**不需要手改 `build.gradle`**。

#### 依赖桶分类

**基础桶（用于普通 Java 库）：**

| 桶名                   | 作用                     |
| ---------------------- | ------------------------ |
| `api`                  | 向下游消费者公开         |
| `implementation`       | 仅项目内部使用           |
| `compile_only`         | 仅编译时需要             |
| `compile_only_api`     | 编译时需要，且向下游公开 |
| `runtime_only`         | 仅运行时需要             |
| `annotation_processor` | 注解处理器               |
| `test_implementation`  | 仅测试编译时             |
| `test_runtime_only`    | 仅测试运行时             |

**deobf 桶（用于需要反混淆的 Mod 依赖）：**

| 桶名                     | 作用                             |
| ------------------------ | -------------------------------- |
| `deobf_api`              | 向下游公开的 Mod API 依赖        |
| `deobf_implementation`   | 内部使用的 Mod 依赖              |
| `deobf_compile_only`     | 仅编译时可见的 Mod 依赖          |
| `deobf_compile_only_api` | 编译时需要且向下游公开的 Mod API |
| `deobf_runtime_only`     | 仅本地运行时带上的 Mod 依赖      |

**特殊桶：**

| 桶名                               | 作用                           |
| ---------------------------------- | ------------------------------ |
| `jarjar`                           | 将依赖打包进最终 jar           |
| `embedded_projects.api`            | 嵌入 Gradle 子项目并向下游公开 |
| `embedded_projects.implementation` | 嵌入 Gradle 子项目但不公开     |

#### 基本写法

简单坐标用字符串：

```toml
[dependencies.deobf_api]
registrate = "com.tterrag.registrate:Registrate:MC1.20-1.3.2"

[dependencies.deobf_compile_only]
kubejs = "dev.latvian.mods:kubejs-forge:2001.6.5-build.16"
```

需要额外参数时（如排除传递依赖），用 inline table：

```toml
[dependencies.deobf_implementation]
architectury = { notation = "dev.architectury:architectury-forge:9.1.12", transitive = false }
```

#### `jarjar` 使用指南

`jarjar` 控制"是否将外部库打包进最终 jar"。和 API 桶的职责不同：

- `jarjar` → 决定**打包与否**
- `api` / `compile_only_api` → 决定**向下游暴露与否**

**场景 1：仅打包，不向下游暴露**

```toml
[dependencies.jarjar]
helper = { notation = "com.example:helper-forge:1.0.0", range = "[1.0.0,)" }
```

**场景 2：既打包，又让下游可以编译访问**

```toml
[dependencies.compile_only_api]
helper_api = { notation = "com.example:helper-forge:1.0.0", range = "[1.0.0,)" }
```

带 `range` 的 `compile_only_api` 条目会自动将该依赖同时加入 `jarjar`。

> 如果已经通过 `[features]` 开启了某项集成，不要在 `[dependencies.*]` 中再手动声明相同依赖，否则会产生重复。

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

代码放在 `src/main/java`，普通 Java/Forge 开发都走这条路径。

#### Kotlin only（仍保留 Java 工具链）

开启 Kotlin，把业务代码放在 `src/main/kotlin`。Gradle 仍然保留 Java source set，因为 Forge、注解处理和生成代码依旧依赖 Java 工具链。

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

控制写入 `mods.toml` 的显示元数据。

| 字段                    | 说明                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------- |
| `logo_file`             | 模组 logo 文件名                                                                            |
| `logo_blur`             | logo 是否应用模糊效果                                                                       |
| `show_as_resource_pack` | 是否显示为资源包                                                                            |
| `show_as_data_pack`     | 是否显示为数据包                                                                            |
| `update_json_url`       | 更新检查 JSON 地址                                                                          |
| `display_url`           | 模组主页链接                                                                                |
| `display_test`          | 兼容性检查策略，允许 `MATCH_VERSION`、`IGNORE_SERVER_VERSION`、`IGNORE_ALL_VERSION`、`NONE` |

```toml
[metadata]
logo_file = "icon.png"
logo_blur = true
display_test = "MATCH_VERSION"
```

### `[mod_relations.*]` — 模组关系声明

声明你的模组与其他模组的关系。模板会据此生成 `mods.toml` 中的条目，并提供给 Modrinth / CurseForge 上传任务。

**支持的关系类型：**

| 类型           | 写入 `mods.toml`    | 影响上传平台 |
| -------------- | ------------------- | ------------ |
| `required`     | 是                  | 是           |
| `optional`     | 是                  | 是           |
| `incompatible` | 否                  | 是           |
| `embedded`     | 否                  | 是           |
| `discouraged`  | Forge 1.20.1 不支持 | —            |

简单写法（仅声明版本范围）：

```toml
[mod_relations.required]
curios = "[5.9.1,)"
```

`required` 和 `optional` 必须提供 `version_range`。如果使用 inline table，`ordering` 只能是 `NONE`、`BEFORE`、`AFTER`，`side` 只能是 `BOTH`、`CLIENT`、`SERVER`。

完整写法（附带平台项目 ID）：

```toml
[mod_relations.optional]
jade = { version_range = "*", modrinth = "nvQzSEkH", curseforge = "324717" }

[mod_relations.incompatible]
optifine = { modrinth = "nCQRBEiR", curseforge = "228404" }

[mod_relations.embedded]
geckolib = { modrinth = "8BmcQJ2H", curseforge = "388172" }
```

`incompatible` 和 `embedded` 在 Forge `1.20.1` 这条线上只用于上传平台关系，所以至少要填一个 `modrinth` 或 `curseforge` 项目 ID；只写模组名不会产生任何效果，模板现在会直接报错。

### `[publish]` — 发布配置

控制 Maven、Modrinth、CurseForge 的发布行为。

| 字段                 | 说明                                    |
| -------------------- | --------------------------------------- |
| `maven_url`          | 远程 Maven 仓库地址（留空则仅本地发布） |
| `curseforge_project` | CurseForge 项目 ID（`0` 表示关闭）      |
| `modrinth_project`   | Modrinth 项目 ID（空字符串表示关闭）    |
| `release_type`       | `alpha`、`beta` 或 `release`            |

**敏感信息的推荐管理方式（按优先级）：**

1. **环境变量**（CI 和正式发布首选）：
    - `MAVEN_URL` / `MAVEN_USER` / `MAVEN_PASSWORD`
    - `MODRINTH_TOKEN` / `CURSEFORGE_TOKEN`

2. **`project.local.toml`**（本机开发，不进 git）：

    ```toml
    [publish]
    maven_user = "your-user"
    maven_password = "your-password"
    modrinth_token = "mcr_xxxxxxxxxxxx"
    curseforge_token = "xxxxxxxxxxxx"

    [run]
    mc_user = "DevPlayer,00000000000000000000000000000001"
    ```

3. **`project.toml` 内联**（仅限临时使用，不要提交到仓库）

`project.toml` 中保留了 credential 字段作为紧急回退，但预期的路径始终是环境变量或 `project.local.toml`。

### `[naming]` — 产物命名

| 字段           | 说明               |
| -------------- | ------------------ |
| `archive_name` | 产物基础名         |
| `jar_format`   | Jar 文件名格式模板 |

支持的 token：`{archive_name}`、`{mod_id}`、`{version}`、`{mc_version}`、`{loader}`。

```toml
[naming]
archive_name = "yourmod"
jar_format = "{archive_name}-{mc_version}-{version}"
```

## 目录结构

```
.
├── project.toml              # 项目主配置（必读）
├── project.local.toml        # 本机私有配置（不进 git）
├── build.gradle              # Gradle 构建脚本（一般不需要修改）
├── settings.gradle           # Gradle 项目设置
├── gradle.properties         # Gradle 全局属性
├── libraries/                # 依赖版本清单
│   └── 1.20.1/
├── src/
│   ├── main/java/            # 主源码目录
│   ├── main/resources/       # 资源文件
│   ├── scaffolds/            # 入口源码和元数据模板
│   │   └── legacy-forge/     #   Forge 平台模板
│   └── templates/            # 共享模板（如 mixins.json）
```

- **`src/scaffolds/legacy-forge/java`**：Forge 平台示例入口代码，构建时自动填充 `mod_id`
- **`src/scaffolds/legacy-forge/templates`**：元数据模板（`mods.toml`），同样按配置生成
- **`src/templates/mixins.json`**：Mixin 配置模板，构建时自动生成 `${mod_id}.mixins.json`
- **`libraries/`**：curated library 版本文件，由模板维护

## 发布指南

### 发布到本地 Maven

```bash
./gradlew publishToMavenLocal
```

### 发布到远程 Maven

1. 在 `project.toml` 中设置 `[publish].maven_url`，或设置环境变量 `MAVEN_URL`
2. 如需认证，设置 `MAVEN_USER` 和 `MAVEN_PASSWORD`
3. 执行：

```bash
./gradlew publish
```

### 上传到 Modrinth / CurseForge

1. 在 `project.toml` 中填写对应的项目 ID
2. 设置对应的 token 环境变量
3. 执行：

```bash
./gradlew buildAndUploadMod
```

上传任务使用 `runtime` jar，而非开发 jar。

## 产物说明

Maven 发布包含四类 jar：

| 产物                      | 用途                                 |
| ------------------------- | ------------------------------------ |
| 默认 jar（无 classifier） | 下游模组编译时依赖                   |
| `runtime` jar             | 平台上传的打包产物，含所有运行时依赖 |
| `sources` jar             | 源码包                               |
| `javadoc` jar             | Javadoc 文档包                       |

## 下游模组如何依赖

如果你的模组发布到了 Maven，下游在 `build.gradle` 中添加：

```gradle
repositories {
    maven { url = "https://your-maven.example/releases" }
}

dependencies {
    implementation "com.yourname.yourmod:yourmod:1.0.0"
}
```

默认发布的 jar 已经是 development jar，**不需要**再包一层 `fg.deobf(...)`。

如果需要使用打包后的 `runtime` 产物：

```gradle
runtimeOnly "com.yourname.yourmod:yourmod:1.0.0:runtime"
```

## Gradle 镜像

仓库默认使用 Gradle 官方 Wrapper 分发地址 (`https://services.gradle.org`)。

在国内网络环境下，如果下载速度较慢，可以修改 `gradle/wrapper/gradle-wrapper.properties` 中的 `distributionUrl` 指向镜像（如阿里云或华为云 Gradle 镜像）。**注意**：

- 修改仅限本机，不要将镜像地址提交到仓库
- 提交前切回官方地址

## 常用命令

```bash
./gradlew build                  # 构建项目
./gradlew runClient              # 启动客户端
./gradlew runServer              # 启动服务端
./gradlew runData                # 运行数据生成
./gradlew genIntellijRuns       # 生成 IntelliJ 运行配置
./gradlew publishToMavenLocal   # 发布到本地 Maven
./gradlew publish               # 发布到远程 Maven
./gradlew buildAndUploadMod     # 构建并上传到平台
```

## 常见问题

### 最少需要改什么才能开始写代码？

三类内容改完即可开始：

1. `project.toml` 中的 `[mod]` 块（`mod_id`、`mod_name`、`group`、`version`）
2. `src/scaffolds/` 下的示例入口类和模板中的包名
3. `src/main/java/` 下的 Mixin 示例类（如不使用 Mixin 可直接删除）

然后运行 `./gradlew build` 验证。

### `features`、`dev_packs`、`[dependencies.*]` 有什么区别？

| 机制               | 用途                 | 影响编译 | 影响运行时 |
| ------------------ | -------------------- | -------- | ---------- |
| `[features]`       | 模板内置的生态集成   | 是       | 是         |
| `[dev_packs]`      | 本地调试辅助模组组合 | 否       | 仅本地     |
| `[dependencies.*]` | 自定义的任意额外依赖 | 取决于桶 | 取决于桶   |

### 什么时候需要 `fg.deobf(...)`？

- 在 `project.toml` 中通过 `deobf_*` 桶添加 Mod 依赖时，模板已处理反混淆
- 消费此模板产出的模组时，使用普通 Maven 坐标即可
