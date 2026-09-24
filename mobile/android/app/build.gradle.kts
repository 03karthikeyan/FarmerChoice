plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mediawave.farmerchoice"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.mediawave.farmerchoice"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Signing with debug keys for testing release build
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        val variant = this
        outputs.all {
            val output = this
            if (output is com.android.build.gradle.internal.api.BaseVariantOutputImpl) {
                val vName = variant.versionName ?: "1.0.0"
                val abi = output.getFilter(com.android.build.OutputFile.ABI)
                if (abi != null) {
                    output.outputFileName = "farmer_choice-${abi}-v${vName}.apk"
                } else {
                    output.outputFileName = "farmer_choice-v${vName}.apk"
                }
            }
        }
    }
}

tasks.register("copyFarmerChoiceApks") {
    doLast {
        val apkDir = File(layout.buildDirectory.asFile.get(), "outputs/apk/release")
        val flutterApkDir = File(layout.buildDirectory.asFile.get(), "outputs/flutter-apk")
        if (apkDir.exists()) {
            apkDir.listFiles()?.forEach { file ->
                if (file.name.endsWith(".apk")) {
                    file.copyTo(File(flutterApkDir, file.name), overwrite = true)
                }
            }
        }
    }
}

tasks.matching { it.name.startsWith("assemble") }.configureEach {
    finalizedBy("copyFarmerChoiceApks")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
