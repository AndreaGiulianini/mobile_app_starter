# Project-specific ProGuard/R8 rules for release builds.
#
# This file is intentionally empty. Coverage already comes from three sources
# that are merged automatically:
#
#   1. proguard-android-optimize.txt — Android platform defaults, pulled in via
#      getDefaultProguardFile() in build.gradle.kts.
#   2. flutter_proguard_rules.pro — injected by the Flutter Gradle plugin. Keeps
#      every io.flutter.embedding.engine.plugins.FlutterPlugin implementation,
#      which is the one thing R8 reliably gets wrong in a Flutter app.
#   3. Each plugin AAR's own consumer-rules.pro, merged by AGP.
#
# Current native plugins: path_provider_android, shared_preferences_android,
# sqflite_android — all three ship their own consumer rules. dio,
# cached_network_image and flutter_bloc are pure Dart and have no R8 surface.
#
# Add rules here only when a release build actually misbehaves. Typical cases:
#   - A native SDK added later that reflects over model classes.
#   - Crash reporting that needs readable stack traces:
#       -keepattributes SourceFile,LineNumberTable
#
# Do not paste blanket `-keep class io.flutter.** { *; }` rules: they defeat R8
# and inflate the APK for no benefit.
#
# Verify any change with `flutter build apk --release` and inspect
# build/app/outputs/mapping/release/ to see what was stripped.
