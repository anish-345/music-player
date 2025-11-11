# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Audio Service - Keep all classes and methods
-keep class com.ryanheise.audioservice.** { *; }
-keep interface com.ryanheise.audioservice.** { *; }
-keepclassmembers class com.ryanheise.audioservice.** { *; }
-keep class * extends com.ryanheise.audioservice.BaseAudioHandler { *; }

# Keep MediaSession and MediaController
-keep class android.support.v4.media.** { *; }
-keep class androidx.media.** { *; }
-dontwarn android.support.v4.media.**
-dontwarn androidx.media.**

# Just Audio
-keep class com.ryanheise.just_audio.** { *; }

# ExoPlayer (used by just_audio)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Media3 (AndroidX Media)
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom model classes
-keep class com.example.myapp.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Ignore warnings for Play Store split install (not used)
-dontwarn com.google.android.play.core.**
-ignorewarnings
