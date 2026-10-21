plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.plugin.compose")
}

val uploadKeystorePath = System.getenv("ANDROID_UPLOAD_KEYSTORE_PATH")
val uploadStorePassword = System.getenv("ANDROID_UPLOAD_STORE_PASSWORD")
val uploadKeyAlias = System.getenv("ANDROID_UPLOAD_KEY_ALIAS")
val uploadKeyPassword = System.getenv("ANDROID_UPLOAD_KEY_PASSWORD")
val releaseSigningEnabled = listOf(uploadKeystorePath, uploadStorePassword, uploadKeyAlias, uploadKeyPassword)
    .all { !it.isNullOrBlank() }

android {
    namespace = "de.kamilunavo.volumecalc"
    compileSdk = 36

    defaultConfig {
        applicationId = "de.kamilunavo.volumecalc"
        minSdk = 26
        targetSdk = 36
        versionCode = 5
        versionName = "1.1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    if (releaseSigningEnabled) {
        signingConfigs {
            create("release") {
                storeFile = file(requireNotNull(uploadKeystorePath))
                storePassword = requireNotNull(uploadStorePassword)
                keyAlias = requireNotNull(uploadKeyAlias)
                keyPassword = requireNotNull(uploadKeyPassword)
            }
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            if (releaseSigningEnabled) signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.activity:activity-compose:1.12.4")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.10.0")
    implementation(platform("androidx.compose:compose-bom:2026.06.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.3.0")
    androidTestImplementation("androidx.test:runner:1.7.0")
    androidTestImplementation(platform("androidx.compose:compose-bom:2026.06.00"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    androidTestImplementation("androidx.test:core:1.7.0")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
