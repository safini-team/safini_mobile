import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyLocalFile = rootProject.file("key.properties")
val keyLocalProperties = Properties()
val hasSigningFile = keyLocalFile.exists()

if (hasSigningFile) {
    keyLocalFile.inputStream().use { keyLocalProperties.load(it) }
}

val requiredSigningKeys = listOf(
    "keyAlias",
    "keyPassword",
    "storeFile",
    "storePassword",
)
val hasSigningConfig = requiredSigningKeys.all {
    !keyLocalProperties.getProperty(it).isNullOrBlank()
}

android {
    namespace = "com.safini.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.safini.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Android 8.0. The Flutter default is 24 (Android 7.0), which is
        // below what the PRD and the landing page both promise, and below
        // what the enforcement layer will need.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasSigningConfig) {
                keyAlias = keyLocalProperties["keyAlias"] as String
                keyPassword = keyLocalProperties["keyPassword"] as String
                storePassword = keyLocalProperties["storePassword"] as String
                storeFile = file(keyLocalProperties["storeFile"] as String)
            }
        }
        getByName("debug") {
            // Shared debug key so every dev's debug build has the same SHA-1
            // (needed for Google Sign-In's Android OAuth client to work for everyone).
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
