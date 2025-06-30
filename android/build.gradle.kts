// Top-level build.gradle.kts
plugins {
    id("com.google.gms.google-services") version "4.4.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // Flutter-compatible
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }
}

// Optional: set namespace as an extra value
val appNamespace by extra("com.example.ecotrack1")

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// NDK version configuration
val ndkVersion by extra("27.0.12077973")

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Apply NDK version to all subprojects
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.BaseExtension> {
                ndkVersion = rootProject.extra["ndkVersion"] as String
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
