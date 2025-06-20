<div align="center"><img height="200" src="src/main/resources/icon.png" width="200"/></div>

# Minecraft NeoForge Mod Development Template

English Version | [中文版](README.md)

This is a modern development template for creating Minecraft 1.20.1+ NeoForge Mods, integrated with popular libraries and tools to simplify the mod development process.

## Features

-   Support for Minecraft 1.20.1+ and NeoForge
-   Integration with popular mod development libraries (JEI, GeckoLib, Curios, etc.)
-   Automated build and publishing pipeline
-   Support for Modrinth and CurseForge publishing
-   Flexible dependency management system
-   Complete development environment configuration

## Requirements

-   **Java 17 JDK** - Java 17 Development Kit is required
-   **IntelliJ IDEA** - Recommended IDE for development
-   **Git** - Version control tool

## Quick Start

### 1. Get the Template

Choose one of the following methods to get the template:

**Method 1: Download ZIP File**

1. Click the "Code" button at the top right of the page
2. Select "Download ZIP"
3. Extract to your development directory

**Method 2: Clone Repository**

```bash
git clone [repository-url]
cd PickAIDForgeTemplate
```

### 2. Project Configuration

Open the `build.txt` file and modify the following essential information:

```properties
# Mod Basic Information
mod_id=your_mod_id
mod_name=Your Mod Name
mod_description=Mod description
mod_authors=Author Name
mod_license=MIT

# Maven Repository Configuration (Optional)
maven_group=com.yourname.yourmod
maven_url=your_maven_repository_url

# Project IDs (Optional, for automatic publishing)
cf_project=CurseForge_Project_ID
modrinth_project=Modrinth_Project_ID
```

### 3. Modify Source Code Files

**Important: You must modify the following files to properly develop your Mod**

#### Modify Package Structure and Main Class

1. **Rename Package Structure**:
   - Rename the `src/main/java/org/pickaid/modid/` directory to your package structure
   - For example: `src/main/java/com/yourname/yourmod/`

2. **Modify Main Class File**:
   Edit `Example.java` (or rename it to your main class name):
   ```java
   package com.yourname.yourmod; // Modify package name
   
   import net.minecraft.resources.ResourceLocation;
   import net.minecraftforge.fml.common.Mod;
   
   @Mod(YourModName.MOD_ID)
   public class YourModName // Modify class name
   {
       public static final String MOD_ID = "yourmodid"; // Change to your mod_id
       public static ResourceLocation id(String path)
       {
           return new ResourceLocation(MOD_ID, path);
       }
   }
   ```

#### Modify Mixin Configuration (if using Mixin)

1. **Rename Mixin Directory**:
   - Rename `src/main/java/org/pickaid/modid/mixins/` to mixins under your package path

2. **Modify Mixin Configuration File**:
   Edit `src/main/resources/mixins.modid.json`:
   ```json
   {
     "required": true,
     "priority": 800,
     "minVersion": "0.8",
     "package": "com.yourname.yourmod.mixins", // Modify package path
     "refmap": "yourmod.refmap.json", // Modify refmap name
     "compatibilityLevel": "JAVA_17",
     "mixins": [],
     "client": [],
     "server": []
   }
   ```

3. **Rename Mixin Configuration File**:
   - Rename `mixins.modid.json` to `mixins.yourmodid.json`

#### Modify META-INF Configuration

**Important: mods.toml has been optimized and usually doesn't need manual modification**

The `src/main/resources/META-INF/mods.toml` file in the template has been modernized:

- **Automatic Variable Substitution**: All configurations are automatically filled from `build.txt`
- **Clear Structure**: Divided into core dependencies and optional dependencies
- **Correct Version Ranges**: Dependencies use proper version number formats
- **Comprehensive Comments**: Easy to understand the purpose of each configuration

To enable optional dependencies (like JEI, Curios, etc.), simply:
1. Uncomment the corresponding version configuration in `build.txt`
2. Uncomment the corresponding dependency in `mods.toml`

**Important Notes**:
- mods.toml now uses variable substitution, no need to manually edit version numbers
- All version numbers are centrally managed in `build.txt`
- Ensure both build.gradle and mods.toml are synchronized when enabling dependencies

**accesstransformer.cfg File**:
- Used for access transformer configuration, usually kept empty
- Add AT rules here if you need to modify private fields or methods

#### Modify Resource Folders

1. **Rename Assets Folder**:
   - Rename `src/main/resources/assets/modid/` to `src/main/resources/assets/yourmodid/`

2. **Optional: Modify Mod Icon**:
   - change `icon.png` in the `src/main/resources/` directory as the mod icon (64x64 pixels)

### 4. Development Environment Setup

1. Open the `build.gradle` file in the project root directory with IntelliJ IDEA
2. Select "Open as Project"
3. Wait for Gradle synchronization to complete
4. Run `./gradlew genEclipseRuns` or `./gradlew genIntellijRuns` to generate run configurations

### 5. Quick Checklist

Before starting development, make sure you have completed all of the following steps:

- [ ] Modify basic information in `build.txt` (mod_id, mod_name, mod_authors, etc.)
- [ ] Rename Java package structure (from `org.pickaid.modid` to your package name)
- [ ] Modify package name, class name, and MOD_ID in the main class file
- [ ] Rename and modify Mixin configuration file `mixins.modid.json`
- [ ] Update package path in Mixin configuration
- [ ] Check `mods.toml` configuration (usually auto-generated, no modification needed)
- [ ] Optional: Enable required dependencies in `mods.toml`
- [ ] Rename assets resource folder (from `modid` to your mod id)
- [ ] Optional: Add mod icon file
- [ ] Run `./gradlew build` to ensure the project compiles successfully

## Environment Variable Configuration

This template supports configuring sensitive information through environment variables, such as Maven repository credentials and publishing tokens.

### Maven Repository Configuration

The following environment variables are supported (higher priority than configuration file):

-   `MAVEN_URL` - Maven repository URL
-   `MAVEN_USER` - Maven username
-   `MAVEN_PASSWORD` - Maven password

### Publishing Configuration

-   `MODRINTH_TOKEN` - Modrinth publishing token
-   `CURSEFORGE_TOKEN` - CurseForge publishing token

### Environment Variable Setup Methods

#### Windows System

**Method 1: Through System Settings**

1. Press `Win + R` to open the Run dialog
2. Type `rundll32 sysdm.cpl,EditEnvironmentVariables` and press Enter
3. Click "New" in the "User Variables" or "System Variables" section
4. Enter the variable name and value
5. Click "OK" to save settings
6. Restart the computer to apply settings

**Method 2: Through Command Line (Temporary)**

```cmd
set MAVEN_USER=your_username
set MAVEN_PASSWORD=your_password
set MODRINTH_TOKEN=your_token
```

**Method 3: Through PowerShell (Persistent)**

```powershell
[Environment]::SetEnvironmentVariable("MAVEN_USER", "your_username", "User")
[Environment]::SetEnvironmentVariable("MAVEN_PASSWORD", "your_password", "User")
[Environment]::SetEnvironmentVariable("MODRINTH_TOKEN", "your_token", "User")
```

#### Linux System

**Method 1: Temporary Setup**

```bash
export MAVEN_USER="your_username"
export MAVEN_PASSWORD="your_password"
export MODRINTH_TOKEN="your_token"
```

**Method 2: Permanent Setup**
Edit `~/.bashrc` or `~/.profile` file:

```bash
echo 'export MAVEN_USER="your_username"' >> ~/.bashrc
echo 'export MAVEN_PASSWORD="your_password"' >> ~/.bashrc
echo 'export MODRINTH_TOKEN="your_token"' >> ~/.bashrc
source ~/.bashrc
```

#### macOS System

**Method 1: Temporary Setup**

```bash
export MAVEN_USER="your_username"
export MAVEN_PASSWORD="your_password"
export MODRINTH_TOKEN="your_token"
```

**Method 2: Permanent Setup**
Edit `~/.zshrc` (or `~/.bash_profile`, depending on your shell):

```bash
echo 'export MAVEN_USER="your_username"' >> ~/.zshrc
echo 'export MAVEN_PASSWORD="your_password"' >> ~/.zshrc
echo 'export MODRINTH_TOKEN="your_token"' >> ~/.zshrc
source ~/.zshrc
```

## Dependency Library Configuration

The template supports various popular mod development libraries. Uncomment the corresponding configuration in `build.txt` to enable:

### JEI (Just Enough Items) Integration

```properties
jei_version=15.2.0.27
```

### GeckoLib Animation Library

```properties
geckolib_version=4.4.9
```

### Curios API Accessory System

```properties
curios_version=5.9.1+1.20.1
```

### Player Animator Library

```properties
playeranimator_version=1.0.2+1.20
```

### Citadel Library

```properties
citadel_version=2.5.4
```

### Other Libraries

```properties
# L2 Series Libraries
l2_library_version=2.5.1-slim
l2damagetracker_version=0.3.7
l2serial_version=1.2.2

# Mixin Extensions
mixin_extras_version=0.2.0-beta.8
```

## Build and Publishing

### Local Build

```bash
# Build Mod
./gradlew build

# Build and Sign (requires signing environment variables)
./gradlew signJar
```

### Automatic Publishing

```bash
# Publish to Modrinth and CurseForge
./gradlew buildAndUploadMod
```

### Version Management

-   When `formal_version` is set to `true`, each build will automatically increment the version number
-   When `formal_version` is set to `false`, use the fixed version number in the configuration file

## Development Tips

### Run Configurations

The template provides the following run configurations:

-   **client** - Client testing environment
-   **server** - Server testing environment
-   **data** - Data generation tool
-   **gameTestServer** - Game test server

### Directory Structure

```
src/main/
├── java/                 # Java source code
├── resources/
│   ├── META-INF/        # Mod metadata
│   ├── assets/          # Resource files (textures, models, etc.)
│   └── data/            # Data files (recipes, loot tables, etc.)
└── generated/           # Auto-generated data files
```

### Development Tools

-   Use `./gradlew runClient` to start client testing
-   Use `./gradlew runServer` to start server testing
-   Use `./gradlew runData` to generate data files

## Troubleshooting

### Common Issues

1. **Build Failed: Java 17 Not Found**

    - Ensure Java 17 JDK is installed
    - Check `JAVA_HOME` environment variable setting

2. **Gradle Sync Failed**

    - Check network connection
    - Try cleaning Gradle cache: `./gradlew clean`

3. **Run Configurations Lost**

    - Regenerate run configurations: `./gradlew genIntellijRuns`

4. **Mixin Error: Class or Package Not Found**
    - Check if the package path in `mixins.yourmodid.json` is correct
    - Ensure Mixin class package names match the configuration file
    - Verify Mixin configuration in `build.gradle` is correct

5. **Resource File Loading Failed**
    - Ensure `assets/yourmodid/` folder name matches your mod_id
    - Check if resource file paths are correct

6. **Main Class Annotation Error**
    - Ensure the value in `@Mod` annotation matches `mod_id` in `build.txt`
    - Check if `MOD_ID` constant in main class is correct

7. **mods.toml Configuration Issues**
    - Check if variables in `build.txt` are correctly filled
    - Ensure dependency version variables are defined and uncommented in `build.txt`
    - Verify `displayURL` and `updateJSONURL` configurations are valid
    - If dependencies are enabled but build fails, check if corresponding gradle dependencies are also enabled

8. **Publishing Failed**
    - Check environment variable configuration
    - Verify project ID settings

### Getting Help

> [!NOTE]
> Since the nf gradle for 1.20.1 is essentially still forge, you generally need to seek help from Forge developers.

-   Check [Forge Official Documentation](https://docs.minecraftforge.net/en/latest/)
-   Check [NeoForge Official Documentation](https://docs.neoforged.net/)
-   Visit [NeoForge Discord](https://discord.neoforged.net/)
-   Submit an [Issue](https://github.com/your-repo/issues)

## License

This template is released under the MIT License. You are free to use, modify, and distribute it.

## Acknowledgments

Thanks to the following projects and developers for their contributions:

-   NeoForge Team
-   Minecraft Forge Community
-   Developers of various dependency libraries

---

Start your mod development journey!
