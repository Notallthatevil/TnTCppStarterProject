#pragma once

#include "Common/TnTBuildConfiguration.h"
#ifndef NDEBUG
#   include <assert.h>
#endif

#ifdef TNT_COMPILER_MSVC
/// Place after struct/class or before type of member.
#   define TNT_ALIGN(x) _declspec(align(x))
#   include <intrin.h>
#   define TNT_FUNC           __FUNCTION__
#   define TNT_NO_INLINE      _declspec(noinline)
#   define TNT_NO_INLINE_WEAK _declspec(noinline) inline
#   define TNT_NO_VTABLE      __declspec(novtable)
#   include <string.h>
#   define TNT_FILENAME (strrchr(__FILE__, '\\') ? strrchr(__FILE__, '\\') + 1 : __FILE__)
#   ifdef NDEBUG
#      define TNT_DEBUG_BREAK  std::abort()
#      define TNT_FORCE_INLINE __forceinline
#      define TNT_FLATTEN      inline
#   else
// clang-format off
#      define TNT_DEBUG_BREAK  __debugbreak(); std::abort()
// clang-format on
#      define TNT_FORCE_INLINE inline
#      define TNT_FLATTEN      inline
#   endif   // NDEBUG

#else
/// Place after struct/class or before type of member.
#   define TNT_ALIGN(x)       __attribute__(aligned(x))
#   define TNT_FUNC           __PRETTY_FUNCTION__
#   define TNT_NO_INLINE      __attribute__((noinline))
#   define TNT_NO_INLINE_WEAK __attribute__((noinline)) __attribute__((weak))
#   define TNT_NO_VTABLE
#   ifdef NDEBUG
#      define TNT_DEBUG_BREAK  std::abort()
#      define TNT_FORCE_INLINE __attribute__((always_inline)) inline
#      define TNT_FLATTEN      __attribute__((flatten))
#   else
// clang-format off
#      define TNT_DEBUG_BREAK  __builtin_trap(); std::abort()
// clang-format on
#      define TNT_FORCE_INLINE
#      define TNT_FLATTEN
#   endif   // NDEBUG

#endif   // TNT_COMPILER_MSVC

#define TNT_THREAD_SAFE

#define TNT_XSTRINGIFY(macro) TNT_STRINGIFY(macro)
#define TNT_STRINGIFY(var)    #var

// clang-format off
#define TNT_INTERFACE(Type) Type() = default; virtual ~Type() = default; Type(const Type&) = default; Type(Type&&) = default; Type& operator=(const Type&) = default; Type& operator=(Type&&) = default;
#define TNT_INTERFACE_NON_COPYABLE(Type) Type() = default; virtual ~Type() = default; Type(const Type&) = delete; Type(Type&&) = default; Type& operator=(const Type&) = delete; Type& operator=(Type&&) = default;
// clang-format on
//
// clang-format off
#define TNT_ENUM_OPERATIONS(enumName)                                                                                                  \
   constexpr enumName  operator~(enumName lhs) { return static_cast<enumName>(~static_cast<int>(lhs)); }                                              \
   constexpr enumName  operator|(enumName lhs, enumName rhs) { return static_cast<enumName>(static_cast<int>(lhs) | static_cast<int>(rhs)); }         \
   constexpr enumName  operator&(enumName lhs, enumName rhs) { return static_cast<enumName>(static_cast<int>(lhs) & static_cast<int>(rhs)); }         \
   constexpr enumName  operator^(enumName lhs, enumName rhs) { return static_cast<enumName>(static_cast<int>(lhs) ^ static_cast<int>(rhs)); }         \
   constexpr enumName &operator|=(enumName &lhs, enumName rhs) { return lhs = static_cast<enumName>(static_cast<int>(lhs) | static_cast<int>(rhs)); } \
   constexpr enumName &operator&=(enumName &lhs, enumName rhs) { return lhs = static_cast<enumName>(static_cast<int>(lhs) & static_cast<int>(rhs)); } \
   constexpr enumName &operator^=(enumName &lhs, enumName rhs) { return lhs = static_cast<enumName>(static_cast<int>(lhs) ^ static_cast<int>(rhs)); }
// clang-format on

#if __has_include(<magic_enum.hpp>)
#   define TNT_MAGIC_ENUM_FLAGS(enumName)                  \
      TNT_ENUM_OPERATIONS(enumName)                        \
      template<>                                           \
      struct magic_enum::customize::enum_range<enumName> { \
         static constexpr bool is_flags = true;            \
      };
#else
#   define TNT_MAGIC_ENUM_FLAGS(enumName) TNT_ENUM_OPERATIONS(enumName)
#endif   // __has_include(<magic_enum.hpp>)
