<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# PickAIDForgeTemplate - Forge 1.19.2 模组模板

[English Version](README_EN.md) | 中文版

`PickAIDForgeTemplate-1.19.2` 只服务于 `Forge 1.19.2`。这条分支已经按 `1.19.2` 的实际生态重新校准，`project.toml` 里的内置版本、CurseMaven file id、本地调试包和发布脚本都对应这一版。

目标：

- 新项目主要改 `project.toml`
- 常见生态依赖尽量不再手改 `build.gradle`
- Java 默认可用，Kotlin 可选启用
- Rust/C/C++ 这类 native 库只打包预编译 JNI/JNA 二进制，不在 Gradle 内编译 native 源码
- 本地调试包、发布配置、产物命名都走统一配置

## 先知道这件事

版本是按 branch 管的，不是按 profile 管的。

- 这条分支只负责 `Forge 1.19.2`
- 不接受 `project.toml [platform]`
- 不接受 `-PtemplateProfile=...`
- `build.txt` 和 `template.toml` 都已经废弃

## 这条分支当前预置了什么

- `Forge 1.19.2` + `ModDevGradle LegacyForge`
- `project.toml` 单入口配置
- 内置 feature 开关：`jei`、`curios`、`geckolib`、`player_animator`、`mixin_extras`
- 内置本地调试包：`basic`、`appleskin`、`combat`、`curios`、`spell`、`kubejs`
- Java + 可选 Kotlin 混合编译
- 预编译 JNI/JNA native 库打包和运行时加载 helper
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

### `[languages]`

Java 始终启用。Kotlin 是可选增强，开启后可以把源码放在 `src/main/kotlin`，并继续和 `src/main/java` 混写：

```toml
[languages]
kotlin = true
```

优先级建议保持为：Java > Kotlin > native。普通 Forge API 和大多数依赖优先走 Java；需要 Kotlin 语法或库生态时再开启 Kotlin；Rust/C/C++ 这类 native 库只作为高级场景使用。

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

### `[native_libraries.*]`

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

构建时模板会把文件打进 jar，并生成 `NativeLibraries` Java helper。运行时可从 `${group}.${mod_id}.runtime.NativeLibraries` 调用 `load("physics")`。

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

## 使用组合

### Java only

保持默认：

```toml
[languages]
kotlin = false
```

代码放在 `src/main/java`。

### Kotlin only

开启 Kotlin，把业务代码放在 `src/main/kotlin`。Java 工具链仍然保留，因为 Forge、注解处理和生成代码依旧依赖 Java 基础设施。

```toml
[languages]
kotlin = true
```

### Java + Kotlin

开启 Kotlin 后，`src/main/java` 和 `src/main/kotlin` 会一起编译。Java 可以调用 Kotlin 暴露的 `@JvmStatic` / 普通 JVM API，Kotlin 也可以直接调用 Java 类。

```toml
[languages]
kotlin = true
```

### Java + native

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

### Java + Kotlin + native

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
