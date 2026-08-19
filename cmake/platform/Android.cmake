# ----------------------------------------------------------------------------
# QGroundControl Android Platform Configuration
# ----------------------------------------------------------------------------

if(NOT ANDROID)
    message(FATAL_ERROR "QGC: Invalid Platform: Android.cmake included but platform is not Android")
endif()

# ----------------------------------------------------------------------------
# Android NDK Version Validation
# ----------------------------------------------------------------------------
if(DEFINED QGC_CONFIG_NDK_FULL_VERSION AND Qt6_VERSION VERSION_GREATER_EQUAL "${QGC_CONFIG_QT_MINIMUM_VERSION}")
    string(REGEX MATCH "^([0-9]+\\.[0-9]+)" _ndk_major_minor "${QGC_CONFIG_NDK_FULL_VERSION}")
    if(_ndk_major_minor AND NOT CMAKE_ANDROID_NDK_VERSION VERSION_GREATER_EQUAL "${_ndk_major_minor}")
        message(FATAL_ERROR "QGC: NDK ${CMAKE_ANDROID_NDK_VERSION} is too old. Qt ${Qt6_VERSION} requires NDK ${_ndk_major_minor}+ (${QGC_CONFIG_NDK_VERSION})")
    endif()
    unset(_ndk_major_minor)
endif()

# ----------------------------------------------------------------------------
# Android Version Number Validation
# ----------------------------------------------------------------------------

if(CMAKE_PROJECT_VERSION_MAJOR GREATER 9)
    message(FATAL_ERROR "QGC: Major version must be single digit (0-9), got: ${CMAKE_PROJECT_VERSION_MAJOR}")
endif()
if(CMAKE_PROJECT_VERSION_MINOR GREATER 9)
    message(FATAL_ERROR "QGC: Minor version must be single digit (0-9), got: ${CMAKE_PROJECT_VERSION_MINOR}")
endif()
if(CMAKE_PROJECT_VERSION_PATCH GREATER 99)
    message(FATAL_ERROR "QGC: Patch version must be two digits (0-99), got: ${CMAKE_PROJECT_VERSION_PATCH}")
endif()

# ----------------------------------------------------------------------------
# Android ABI to Bitness Code Mapping
# ----------------------------------------------------------------------------
set(ANDROID_BITNESS_CODE)
if(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a" OR CMAKE_ANDROID_ARCH_ABI STREQUAL "x86")
    set(ANDROID_BITNESS_CODE 34)
elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a" OR CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
    set(ANDROID_BITNESS_CODE 66)
else()
    message(FATAL_ERROR "QGC: Unsupported Android ABI: ${CMAKE_ANDROID_ARCH_ABI}")
endif()

# ----------------------------------------------------------------------------
# Android Version Code Generation
# ----------------------------------------------------------------------------
set(ANDROID_PATCH_VERSION ${CMAKE_PROJECT_VERSION_PATCH})
if(CMAKE_PROJECT_VERSION_PATCH LESS 10)
    set(ANDROID_PATCH_VERSION "0${CMAKE_PROJECT_VERSION_PATCH}")
endif()

set(ANDROID_VERSION_CODE "${ANDROID_BITNESS_CODE}${CMAKE_PROJECT_VERSION_MAJOR}${CMAKE_PROJECT_VERSION_MINOR}${ANDROID_PATCH_VERSION}000")
message(STATUS "QGC: Android version code: ${ANDROID_VERSION_CODE}")

set(QGC_ANDROID_PROPERTIES_FILE "${CMAKE_BINARY_DIR}/qgc-android-config.properties")
set(QGC_ANDROID_PROPERTIES_CONTENT
    "QGC_ANDROID_COMPILE_SDK_VERSION=${QGC_QT_ANDROID_COMPILE_SDK_VERSION}\n"
    "QGC_ANDROID_TARGET_SDK_VERSION=${QGC_QT_ANDROID_TARGET_SDK_VERSION}\n"
    "QGC_ANDROID_MIN_SDK_VERSION=${QGC_QT_ANDROID_MIN_SDK_VERSION}\n"
    "QGC_ANDROID_VERSION_CODE=${ANDROID_VERSION_CODE}\n"
    "QGC_ANDROID_VERSION_NAME=${CMAKE_PROJECT_VERSION}\n"
    "QGC_CPM_JAVA_SRC_DIR=${CMAKE_BINARY_DIR}/extra_java_sources\n"
)
string(JOIN "" QGC_ANDROID_PROPERTIES_CONTENT ${QGC_ANDROID_PROPERTIES_CONTENT})
file(GENERATE
    OUTPUT "${QGC_ANDROID_PROPERTIES_FILE}"
    CONTENT "${QGC_ANDROID_PROPERTIES_CONTENT}"
)

# ----------------------------------------------------------------------------
# FINAL ANDROID APP SETTINGS (BRANDING APPLIED HERE)
# ----------------------------------------------------------------------------

set_target_properties(${CMAKE_PROJECT_NAME}
    PROPERTIES
        QT_ANDROID_MIN_SDK_VERSION ${QGC_QT_ANDROID_MIN_SDK_VERSION}
        QT_ANDROID_TARGET_SDK_VERSION ${QGC_QT_ANDROID_TARGET_SDK_VERSION}
        QT_ANDROID_COMPILE_SDK_VERSION ${QGC_QT_ANDROID_COMPILE_SDK_VERSION}

        QT_ANDROID_PACKAGE_NAME "${QGC_ANDROID_PACKAGE_NAME}"
        QT_ANDROID_PACKAGE_SOURCE_DIR "${QGC_ANDROID_PACKAGE_SOURCE_DIR}"

        QT_ANDROID_VERSION_NAME "${CMAKE_PROJECT_VERSION}"
        QT_ANDROID_VERSION_CODE ${ANDROID_VERSION_CODE}

        QT_ANDROID_APP_NAME "KapYah GCS"
        QT_ANDROID_APP_ICON "@mipmap/ic_launcher"

        QT_QML_ROOT_PATH "${CMAKE_SOURCE_DIR}"
)

# ----------------------------------------------------------------------------
# Permissions (unchanged)
# ----------------------------------------------------------------------------

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.BLUETOOTH_SCAN
    ATTRIBUTES minSdkVersion 31 usesPermissionFlags neverForLocation
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.BLUETOOTH_CONNECT
    ATTRIBUTES minSdkVersion 31 usesPermissionFlags neverForLocation
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.CHANGE_WIFI_MULTICAST_STATE
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.WRITE_EXTERNAL_STORAGE
    ATTRIBUTES maxSdkVersion 32
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.READ_EXTERNAL_STORAGE
    ATTRIBUTES maxSdkVersion 33
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.VIBRATE
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.INTERNET
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.WAKE_LOCK
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.ACCESS_NETWORK_STATE
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.ACCESS_FINE_LOCATION
)

qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.ACCESS_COARSE_LOCATION
)

message(STATUS "QGC: Android platform configuration applied")