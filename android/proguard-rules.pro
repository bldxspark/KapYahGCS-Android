# Qt framework classes - must be preserved for JNI
-keep class org.qtproject.qt.** { *; }
-keep class org.kde.necessitas.** { *; }
-keep class ru.dublgis.** { *; }
-keep class com.falsinsoft.qtandroidtools.** { *; }

# QGC classes with native methods
-keepclasseswithmembers class com.kapyah.gcs.QGCActivity {
    native <methods>;
}
-keepclasseswithmembers class com.kapyah.gcs.QGCUsbSerialManager {
    native <methods>;
}
# Static methods are resolved from C++ by method name/signature.
-keepclassmembers class com.kapyah.gcs.QGCActivity {
    public static *;
}
-keepclassmembers class com.kapyah.gcs.QGCUsbSerialManager {
    public static *;
}
-keep class com.kapyah.gcs.QGCUsbId { *; }
-keep class com.kapyah.gcs.QGCUsbSerialProber { *; }
-keep class com.kapyah.gcs.QGCLogger { *; }
-keep class com.kapyah.gcs.QGCFtdiSerialDriver { *; }
-keep class com.kapyah.gcs.QGCFtdiSerialDriver$QGCFtdiSerialPort { *; }
-keep class com.kapyah.gcs.QGCFtdiDriver { *; }
-keep class com.kapyah.gcs.QGCSDLManager { *; }

# SDL - native method stubs required for JNI registration
-keep class org.libsdl.app.** { *; }

# GStreamer - native callbacks
-keep class org.freedesktop.gstreamer.** { *; }

# usb-serial-for-android
-keep class com.hoho.android.usbserial.** { *; }

# AndroidX FileProvider
-keep class androidx.core.content.FileProvider { *; }

# Preserve native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve enums (used by serialization)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}