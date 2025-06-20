# Minecraft NeoForge Mod 开发模板

[English Version](README_EN.md) | 中文版

这是一个用于创建 Minecraft 1.20.1+ NeoForge Mod 的现代化开发模板，集成了常用的库和工具，简化了 Mod 开发流程。

## 功能特性

-   支持 Minecraft 1.20.1+ 和 NeoForge
-   集成多种流行的 Mod 开发库（JEI、GeckoLib、Curios 等）
-   自动化构建和发布流程
-   支持 Modrinth 和 CurseForge 发布
-   灵活的依赖管理系统
-   完整的开发环境配置

## 环境要求

-   **Java 17 JDK** - 必须安装 Java 17 开发工具包
-   **IntelliJ IDEA** - 推荐使用 IntelliJ IDEA 作为开发环境
-   **Git** - 版本控制工具

## 快速开始

### 1. 获取模板

选择以下方式之一获取模板：

**方式一：下载 ZIP 文件**

1. 点击页面右上角的 "Code" 按钮
2. 选择 "Download ZIP"
3. 解压到你的开发目录

**方式二：克隆仓库**

```bash
git clone [仓库地址]
cd PickAIDForgeTemplate
```

### 2. 项目配置

打开 `build.txt` 文件，修改以下必要信息：

```properties
# Mod 基本信息
mod_id=你的mod的id
mod_name=你的Mod名称
mod_description=Mod描述
mod_authors=作者名称
mod_license=MIT

# Maven 仓库配置（可选）
maven_group=com.yourname.yourmod
maven_url=你的maven仓库地址

# 项目 ID（可选，用于自动发布）
cf_project=CurseForge项目ID
modrinth_project=Modrinth项目ID
```

### 3. 修改源代码文件

**重要：必须修改以下文件才能正常开发你的Mod**

#### 修改包结构和主类

1. **重命名包结构**：
   - 将 `src/main/java/org/pickaid/modid/` 目录重命名为你的包结构
   - 例如：`src/main/java/com/yourname/yourmod/`

2. **修改主类文件**：
   编辑 `Example.java`（或重命名为你的主类名）：
   ```java
   package com.yourname.yourmod; // 修改包名
   
   import net.minecraft.resources.ResourceLocation;
   import net.minecraftforge.fml.common.Mod;
   
   @Mod(YourModName.MOD_ID)
   public class YourModName // 修改类名
   {
       public static final String MOD_ID = "yourmodid"; // 修改为你的mod_id
       public static ResourceLocation id(String path)
       {
           return new ResourceLocation(MOD_ID, path);
       }
   }
   ```

#### 修改Mixin配置（如果使用Mixin）

1. **重命名Mixin目录**：
   - 将 `src/main/java/org/pickaid/modid/mixins/` 重命名为你的包路径下的mixins

2. **修改Mixin配置文件**：
   编辑 `src/main/resources/mixins.modid.json`：
   ```json
   {
     "required": true,
     "priority": 800,
     "minVersion": "0.8",
     "package": "com.yourname.yourmod.mixins", // 修改包路径
     "refmap": "yourmod.refmap.json", // 修改refmap名称
     "compatibilityLevel": "JAVA_17",
     "mixins": [],
     "client": [],
     "server": []
   }
   ```

3. **重命名Mixin配置文件**：
   - 将 `mixins.modid.json` 重命名为 `mixins.yourmodid.json`

#### 修改META-INF配置

**重要：mods.toml 已经过优化，通常不需要手动修改**

模板中的 `src/main/resources/META-INF/mods.toml` 文件已经过现代化改进：

- **自动变量替换**：所有配置都会从 `build.txt` 自动填充
- **清晰的结构**：分为核心依赖和可选依赖两部分
- **正确的版本范围**：依赖项使用正确的版本号格式
- **中文注释**：便于理解各个配置的作用

如需启用可选依赖（如JEI、Curios等），只需：
1. 在 `build.txt` 中取消注释相应的版本配置
2. 在 `mods.toml` 中取消注释对应的依赖项

**重要提示**：
- mods.toml 现在使用变量替换，无需手动编辑版本号
- 所有版本号都在 `build.txt` 中统一管理
- 确保启用依赖时，build.gradle 和 mods.toml 都要同步操作

**accesstransformer.cfg 文件**：
- 用于访问转换器配置，通常保持空白即可
- 如需修改私有字段或方法，在此文件中添加AT规则

#### 修改资源文件夹

1. **重命名assets文件夹**：
   - 将 `src/main/resources/assets/modid/` 重命名为 `src/main/resources/assets/yourmodid/`

2. **可选：添加mod图标**：
   - 在 `src/main/resources/` 目录下添加 `yourmodid.png` 作为mod图标（64x64像素）

### 4. 开发环境设置

1. 使用 IntelliJ IDEA 打开项目根目录下的 `build.gradle` 文件
2. 选择 "Open as Project"
3. 等待 Gradle 同步完成
4. 运行 `./gradlew genEclipseRuns` 或 `./gradlew genIntellijRuns` 生成运行配置

### 5. 快速检查清单

在开始开发前，确保你已完成以下所有步骤：

- [ ] 修改 `build.txt` 中的基本信息（mod_id、mod_name、mod_authors等）
- [ ] 重命名Java包结构（从 `org.pickaid.modid` 改为你的包名）
- [ ] 修改主类文件中的包名、类名和MOD_ID
- [ ] 重命名并修改Mixin配置文件 `mixins.modid.json`
- [ ] 更新Mixin配置中的包路径
- [ ] 检查 `mods.toml` 配置（通常自动生成，无需修改）
- [ ] 可选：在 `mods.toml` 中启用需要的依赖项
- [ ] 重命名assets资源文件夹（从 `modid` 改为你的mod id）
- [ ] 可选：添加mod图标文件
- [ ] 运行 `./gradlew build` 确保项目能正常编译

## 环境变量配置

本模板支持通过环境变量配置敏感信息，如 Maven 仓库凭据和发布令牌。

### Maven 仓库配置

支持以下环境变量（优先级高于配置文件）：

-   `MAVEN_URL` - Maven 仓库地址
-   `MAVEN_USER` - Maven 用户名
-   `MAVEN_PASSWORD` - Maven 密码

### 发布配置

-   `MODRINTH_TOKEN` - Modrinth 发布令牌
-   `CURSEFORGE_TOKEN` - CurseForge 发布令牌

### 环境变量设置方法

#### Windows 系统

**方法一：通过系统设置**

1. 按 `Win + R` 键打开运行对话框
2. 输入 `rundll32 sysdm.cpl,EditEnvironmentVariables` 并按回车
3. 在 "用户变量" 或 "系统变量" 区域点击 "新建"
4. 输入变量名和变量值
5. 点击 "确定" 保存设置
6. 重启计算机使设置生效

**方法二：通过命令行（临时）**

```cmd
set MAVEN_USER=你的用户名
set MAVEN_PASSWORD=你的密码
set MODRINTH_TOKEN=你的token
```

**方法三：通过 PowerShell（持久）**

```powershell
[Environment]::SetEnvironmentVariable("MAVEN_USER", "你的用户名", "User")
[Environment]::SetEnvironmentVariable("MAVEN_PASSWORD", "你的密码", "User")
[Environment]::SetEnvironmentVariable("MODRINTH_TOKEN", "你的token", "User")
```

#### Linux 系统

**方法一：临时设置**

```bash
export MAVEN_USER="你的用户名"
export MAVEN_PASSWORD="你的密码"
export MODRINTH_TOKEN="你的token"
```

**方法二：永久设置**
编辑 `~/.bashrc` 或 `~/.profile` 文件：

```bash
echo 'export MAVEN_USER="你的用户名"' >> ~/.bashrc
echo 'export MAVEN_PASSWORD="你的密码"' >> ~/.bashrc
echo 'export MODRINTH_TOKEN="你的token"' >> ~/.bashrc
source ~/.bashrc
```

#### macOS 系统

**方法一：临时设置**

```bash
export MAVEN_USER="你的用户名"
export MAVEN_PASSWORD="你的密码"
export MODRINTH_TOKEN="你的token"
```

**方法二：永久设置**
编辑 `~/.zshrc`（或 `~/.bash_profile`，取决于你的 shell）：

```bash
echo 'export MAVEN_USER="你的用户名"' >> ~/.zshrc
echo 'export MAVEN_PASSWORD="你的密码"' >> ~/.zshrc
echo 'export MODRINTH_TOKEN="你的token"' >> ~/.zshrc
source ~/.zshrc
```

## 依赖库配置

模板支持多种常用的 Mod 开发库，在 `build.txt` 中取消注释相应配置即可启用：

### JEI（Just Enough Items）集成

```properties
jei_version=15.2.0.27
```

### GeckoLib 动画库

```properties
geckolib_version=4.4.9
```

### Curios API 饰品系统

```properties
curios_version=5.9.1+1.20.1
```

### Player Animator 玩家动画

```properties
playeranimator_version=1.0.2+1.20
```

### Citadel 前置库

```properties
citadel_version=2.5.4
```

### 其他库

```properties
# L2 系列库
l2_library_version=2.5.1-slim
l2damagetracker_version=0.3.7
l2serial_version=1.2.2

# Mixin 扩展
mixin_extras_version=0.2.0-beta.8
```

## 构建和发布

### 本地构建

```bash
# 构建 Mod
./gradlew build

# 构建并签名（需要配置签名环境变量）
./gradlew signJar
```

### 自动发布

```bash
# 发布到 Modrinth 和 CurseForge
./gradlew buildAndUploadMod
```

### 版本管理

-   将 `formal_version` 设置为 `true` 时，每次构建会自动递增版本号
-   将 `formal_version` 设置为 `false` 时，使用配置文件中的固定版本号

## 开发提示

### 运行配置

模板提供了以下运行配置：

-   **client** - 客户端测试环境
-   **server** - 服务器测试环境
-   **data** - 数据生成工具
-   **gameTestServer** - 游戏测试服务器

### 目录结构

```
src/main/
├── java/                 # Java 源代码
├── resources/
│   ├── META-INF/        # Mod 元数据
│   ├── assets/          # 资源文件（贴图、模型等）
│   └── data/            # 数据文件（配方、战利品表等）
└── generated/           # 自动生成的数据文件
```

### 开发工具

-   使用 `./gradlew runClient` 启动客户端测试
-   使用 `./gradlew runServer` 启动服务器测试
-   使用 `./gradlew runData` 生成数据文件

## 故障排除

### 常见问题

1. **构建失败：找不到 Java 17**

    - 确保安装了 Java 17 JDK
    - 检查 `JAVA_HOME` 环境变量设置

2. **Gradle 同步失败**

    - 检查网络连接
    - 尝试清理 Gradle 缓存：`./gradlew clean`

3. **运行配置丢失**

    - 重新生成运行配置：`./gradlew genIntellijRuns`

4. **Mixin 错误：找不到类或包**
    - 检查 `mixins.yourmodid.json` 中的包路径是否正确
    - 确保Mixin类的包名与配置文件中的包名一致
    - 验证 `build.gradle` 中的Mixin配置是否正确

5. **资源文件加载失败**
    - 确保 `assets/yourmodid/` 文件夹名称与你的mod_id一致
    - 检查资源文件路径是否正确

6. **主类注解错误**
    - 确保 `@Mod` 注解中的值与 `build.txt` 中的 `mod_id` 一致
    - 检查主类中的 `MOD_ID` 常量是否正确

7. **mods.toml 配置问题**
    - 检查 `build.txt` 中的变量是否正确填写
    - 确保依赖项的版本变量在 `build.txt` 中已定义并取消注释
    - 验证 `displayURL` 和 `updateJSONURL` 配置是否有效
    - 如果启用了依赖但构建失败，检查对应的 gradle 依赖是否也已启用

8. **发布失败**
    - 检查环境变量配置
    - 验证项目 ID 设置

### 获取帮助

> [!NOTE]
> 由于1.20.1的nf gradle本质上依旧是forge，你一般需要向Forge开发者寻求帮助。

-   查看 [Forge 官方文档](https://docs.minecraftforge.net/en/latest/)
-   查看 [NeoForge 官方文档](https://docs.neoforged.net/)
-   访问 [NeoForge Discord](https://discord.neoforged.net/)
-   提交 [Issue](https://github.com/your-repo/issues)

## 许可证

本模板基于 MIT 许可证发布，你可以自由使用、修改和分发。

## 致谢

感谢以下项目和开发者的贡献：

-   NeoForge 团队
-   Minecraft Forge 社区
-   各种依赖库的开发者们

---

开始你的 Mod 开发之旅吧！
