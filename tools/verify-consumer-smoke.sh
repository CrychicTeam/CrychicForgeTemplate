#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/gedwen/Documents/programing/MC/PickAIDForgeTemplate"
RUN_ROOT="$(mktemp -d /tmp/pickaid-template-consumer.XXXXXX)"
SOURCE_HOME="/Users/gedwen"

cleanup() {
    rm -rf "${RUN_ROOT}"
}
trap cleanup EXIT

TMP_DIR="${RUN_ROOT}/consumer"

export HOME="${RUN_ROOT}/home"
export GRADLE_USER_HOME="${SOURCE_HOME}/.gradle"

mkdir -p "${TMP_DIR}/src/test/java/example" "${HOME}"
LOCAL_M2="${HOME}/.m2/repository"

cat > "${TMP_DIR}/settings.gradle" <<'EOF'
pluginManagement {
    repositories {
        gradlePluginPortal()
        maven { url = 'https://maven.minecraftforge.net/' }
        maven { url = 'https://maven.parchmentmc.org' }
    }
}

plugins {
    id 'org.gradle.toolchains.foojay-resolver-convention' version '0.5.0'
}
EOF

cat > "${TMP_DIR}/build.gradle" <<'EOF'
plugins {
    id 'net.minecraftforge.gradle' version '[6.0,6.2)'
    id 'org.parchmentmc.librarian.forgegradle' version '1.+'
}

java.toolchain.languageVersion = JavaLanguageVersion.of(17)

minecraft {
    mappings channel: 'parchment', version: '2023.09.03-1.20.1'
}

repositories {
    mavenLocal()
    mavenCentral()
    maven { url = 'https://maven.minecraftforge.net/' }
    maven { url = 'https://maven.parchmentmc.org' }
    maven { url = 'https://maven.tterrag.com/' }
    maven { url = 'https://maven.architectury.dev' }
    maven { url = 'https://maven.latvian.dev/releases' }
    maven { url = 'https://jitpack.io' }
    maven { url = 'https://maven.mihono.cn/repository/pickaid1201/' }
}

dependencies {
    minecraft "net.minecraftforge:forge:1.20.1-47.4.10"
    testImplementation platform("org.junit:junit-bom:5.10.2")
    testImplementation "org.junit.jupiter:junit-jupiter"
    testRuntimeOnly "org.junit.platform:junit-platform-launcher"
    implementation "com.mihono.pickaid:example:0.0.1"
}

tasks.withType(Test).configureEach {
    useJUnitPlatform()
}
EOF

cat > "${TMP_DIR}/src/test/java/example/TemplateConsumerSmokeTest.java" <<'EOF'
package example;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import org.junit.jupiter.api.Test;

class TemplateConsumerSmokeTest {
    @Test
    void templateDependencyPullsTransitivelyNeededDevelopmentLibraries() throws Exception {
        assertNotNull(Class.forName("org.pickaid.modid.Example"));
        assertNotNull(Class.forName("com.tterrag.registrate.AbstractRegistrate"));
    }
}
EOF

cd "${ROOT}"
bash ./gradlew publishToMavenLocal --no-daemon "-Duser.home=${HOME}"
bash ./gradlew -p "${TMP_DIR}" test --no-daemon "-Duser.home=${HOME}"
