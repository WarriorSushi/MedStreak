plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlin-kapt")
    id("com.google.gms.google-services") // If using Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

// Use Java 11 compatibility for all tasks
tasks.withType<JavaCompile>().configureEach {
    sourceCompatibility = JavaVersion.VERSION_11.toString()
    targetCompatibility = JavaVersion.VERSION_11.toString()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions {
        jvmTarget = "11"
    }
}

android {
    namespace = "com.medstreak.medstreak"
    compileSdk = 35
    
    // Set NDK version required by Firebase and other plugins
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.medstreak.medstreak"
        minSdk = 23 // Updated from 21 to 23 for Firebase Auth compatibility
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        
        // Enable multidex support
        multiDexEnabled = true
        
        // Enable vector drawable support
        vectorDrawables.useSupportLibrary = true
    }

    buildTypes {
        release {
            // Enable code shrinking and obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            // Enable test coverage in debug builds
            isTestCoverageEnabled = true
            // Removed applicationIdSuffix to match Firebase configuration
        }
    }
    
    // Enable view binding
    buildFeatures {
        viewBinding = true
        buildConfig = true
    }
    
    // Configure Java 11 compatibility is already set above
}

flutter {
    source = "../.."
}

// Add core library desugaring for Java 8+ APIs
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Add other dependencies here if needed
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:32.7.0")) // If using Firebase
    
    // Add testing dependencies
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
