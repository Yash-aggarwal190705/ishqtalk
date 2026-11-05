# Flutter/Dart engine & embedder.
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugin.**
-dontwarn io.flutter.util.**

# Application + plugins (kept so JNI/platform channels keep working).
-keep class com.example.ishqtalk.MainActivity { *; }
-keep class io.flutter.plugins.** { *; }

# Provider/generated code.
-keepattributes *Annotation*
-keepclassmembers enum * { public static **[] values(); }
