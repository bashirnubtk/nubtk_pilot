import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// ফ্ল্যাটারের লোকাল প্রোপার্টিজ থেকে ভার্সন ডাটা লোড করা
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    // আপনার প্রজেক্টের ইউনিক প্যাকেজ নাম
    namespace = "com.nubtk.pilot"
    compileSdk = flutter.compileSdkVersion
    
    // NDK ভার্সন আপডেট করা হয়েছে যাতে প্লাগইন এরর না দেয়
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.nubtk.pilot"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        
        // মাল্টি-ডেক্স সাপোর্ট এনাবল করা (বড় প্রজেক্টের জন্য জরুরি)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // রিলিজ মোডে কোড ছোট করার জন্য নিচের অপশনগুলো ব্যবহার করা হয়
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ফায়ারবেস এবং অন্যান্য লাইব্রেরি
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("androidx.multidex:multidex:2.0.1")
}