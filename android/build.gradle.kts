buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.1.2' // Keep the existing Gradle dependency
        classpath 'com.google.gms:google-services:4.3.10'  // Add this line for Firebase
        implementation platform('com.google.firebase:firebase-bom:33.12.0')
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}