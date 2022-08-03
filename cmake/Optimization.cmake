include_guard()

macro(enable_interprocedural_optimization project_name)
   if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.18.0")
      if(CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
         include(CheckIPOSupported)
         check_ipo_supported(RESULT result OUTPUT output)
         if(result)
            # If a static library of this project is used in another project that does not have `CMAKE_INTERPROCEDURAL_OPTIMIZATION` enabled, a linker error might happen.
            # TODO set this option in `package_project` function.
            message(STATUS "Interprocedural optimization is enabled. In other projects, linking with the compiled libraries of this project might require `set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)`")
            set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
            set_target_properties(${project_name} PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
         else()
            message(WARNING "Interprocedural Optimization is not supported. Not using it. Here is the error log: ${output}")
         endif()
      endif()
   else()
      message(WARNING "Consider upgrading CMake to the latest version. CMake ${CMAKE_VERSION} does not support ENABLE_INTERPROCEDURAL_OPTIMIZATION.")
   endif()
endmacro()

set(MSVC_PLATFORM_INSTRINSICS "AVX2" CACHE STRING "Specifies what command to send to CL /arch argument. See https://docs.microsoft.com/en-us/cpp/build/reference/arch-x64")
macro(enable_native_optimization project_name)
   detect_architecture(_arch)
      if("${_arch}" STREQUAL "x64")
         message(STATUS "Enabling the optimizations specific to the current build machine (less portable)")
      if(MSVC)
         target_compile_options(${project_name} INTERFACE /arch:${MSVC_PLATFORM_INSTRINSICS})
      else()
         target_compile_options(${project_name} INTERFACE -march=native)
      endif()
   endif()
endmacro()