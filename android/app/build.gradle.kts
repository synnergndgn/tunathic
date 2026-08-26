import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningPropertiesFile = rootProject.file("key.properties")
val releaseSigningProperties =
    Properties().apply {
        if (releaseSigningPropertiesFile.exists()) {
            releaseSigningPropertiesFile.inputStream().use(::load)
        }
    }
val releaseSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingReleaseSigningKeys =
    releaseSigningKeys.filter { releaseSigningProperties.getProperty(it).isNullOrBlank() }
val releaseKeystoreFile =
    releaseSigningProperties
        .getProperty("storeFile")
        ?.takeIf(String::isNotBlank)
        ?.let(rootProject::file)
val hasReleaseSigningCredentials =
    releaseSigningPropertiesFile.exists() &&
        missingReleaseSigningKeys.isEmpty() &&
        releaseKeystoreFile?.isFile == true

android {
    namespace = "dev.gundev.tunathic"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "dev.gundev.tunathic"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        externalNativeBuild {
            cmake {
                arguments += "-DANDROID_STL=c++_shared"
                cppFlags += "-std=c++17"
            }
        }
    }

    buildFeatures {
        prefab = true
        buildConfig = true
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    if (hasReleaseSigningCredentials) {
        signingConfigs {
            create("release") {
                storeFile = releaseKeystoreFile
                storePassword = releaseSigningProperties.getProperty("storePassword")
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigningCredentials) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    doFirst {
        if (!hasReleaseSigningCredentials) {
            val detail =
                when {
                    !releaseSigningPropertiesFile.exists() ->
                        "android/key.properties does not exist"
                    missingReleaseSigningKeys.isNotEmpty() ->
                        "android/key.properties is missing: ${missingReleaseSigningKeys.joinToString()}"
                    else -> "the configured upload keystore does not exist"
                }
            throw GradleException(
                "Release signing is not configured: $detail. " +
                    "Copy android/key.properties.example to android/key.properties, " +
                    "use the authorized upload-key values, and keep both files out of Git.",
            )
        }
    }
}

dependencies {
    implementation("com.google.oboe:oboe:1.10.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
