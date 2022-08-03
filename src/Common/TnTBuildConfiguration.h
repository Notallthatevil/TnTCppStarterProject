#pragma once

constexpr int TNT_VERSION_MAJOR = 0;
constexpr int TNT_VERSION_MINOR = 1;
constexpr int TNT_VERSION_PATCH = 0;

#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
#   define WINDOWS_LEAN_AND_MEAN
#   define NOMINMAX
#   ifdef _WIN64
#      define TNT_PLATFORM_WINDOWS
#   else
#      error Only x64 builds are supported!
#   endif
#elif defined(__APPLE__) || defined(__MACH__)   // IOS and IPhone simulator both define __APPLE__ so need to check them in the following order.
#   include <TargetConditionals.h>
#   if TARGET_IPHONE_SIMULATOR
#      define TNT_PLATFORM_IOS_SIMULATOR
#      error IOS simulator builds are not currently supported!
#   elif TARGET_OS_IPHONE
#      error IOS builds are not currently supported!
#   elif TARGET_OS_MAC
#      error MAC os builds are not currently supported!
#   else
#      error "Unknown Apple platform"
#   endif
#elif defined(__ANDROID__)   // Android defines __linux__ so must be checked first.
#   define TNT_PLATFORM_ANDROID
#   error Android builds are not currently supported!
#elif defined(__linux__)
#   define TNT_PLATFORM_LINUX
#   error Linux builds are not currently supported!
#endif

#ifdef _MSC_VER
#   define TNT_COMPILER_MSVC
#elif defined(__clang__)
#   define TNT_COMPILER_CLANG
#elif defined(__GNUC__)
#   define TNT_COMPILER_GCC
#else
#   error Unsupported compiler!
#endif

#ifdef TNT_SHARED
#   ifdef TNT_COMPILE
#      ifdef TNT_COMPILER_MSVC
#         define TNT_API __declspec(dllexport)
#      else
#         define TNT_API __attribute__((__visibility__("default")))
#      endif   // TNT_COMPILER_MSVC
#   else
#      ifdef TNT_COMPILER_MSVC
#         define TNT_API __declspec(dllimport)
#      else
#         define TNT_API
#      endif   // TNT_COMPILER_MSVC
#   endif      // TNT_COMPILE
#else
#   define TNT_API
#endif
