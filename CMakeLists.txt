cmake_minimum_required(VERSION 3.20)

project(TnTCppStartProject
   VERSION 0.0.1
   DESCRIPTION ""
   HOMEPAGE_URL "https://github.com/Notallthatevil/TnTCppStarterProject"
   LANGUAGES CXX
)

include(FetchContent)
include(cmake/Utilities.cmake)
include(cmake/PreventInSourceBuilds.cmake)
assure_out_of_source_builds()

# Link this 'library' to set the c++ standard / compile-time options requested
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_23)

# Link this 'library' to use the warnings specified in CompilerOptions.cmake
add_library(project_warnings INTERFACE)

# Link to this library to include common project dependencies such as graphics APIs
add_library(project_dependencies INTERFACE)

# Import project wide settings
include(cmake/ProjectOptions.cmake)

# Import common compiler settings
include(cmake/CompilerOptions.cmake)
set_project_warnings(project_warnings) # Add as linkable project to enable warnings for project.
ignore_warnings_and_diagnostics_from_external(project_options) # Currently only supported by MSVC. Ignores warnings coming from external includes.
add_module_include_dir(project_options)

# Import Doxygen support
include(cmake/Doxygen.cmake)
#enable_doxygen("")

# Import common linker options
include(cmake/LinkerOptions.cmake)
configure_linker(project_options)

# Import optimizations
include(cmake/Optimization.cmake)
if(CMAKE_BUILD_TYPE STREQUAL "Release")
   enable_native_optimization(project_options)
   enable_interprocedural_optimization(project_options)
endif()

# Import sanitizers
include(cmake/Sanitizers.cmake)

# Import static analyzer options.
include(cmake/StaticAnalyzers.cmake)

# Import testing utilities
include(cmake/TestingUtils.cmake)

# Include ability to fetch common external dependencies
include(cmake/FetchDependencies.cmake)

add_subdirectory(src)

# Adding the tests:
option(ENABLE_TESTING "Enable the tests" ON)
if(ENABLE_TESTING)
  enable_testing()
  message(STATUS "Building Tests")
  add_subdirectory(test)
endif()

option(ENABLE_FUZZING "Enable the fuzz tests" OFF)
if(ENABLE_FUZZING)
  message("Building Fuzz Tests, using fuzzing sanitizer https://www.llvm.org/docs/LibFuzzer.html")
  add_subdirectory(fuzz_test)
endif()

# If MSVC is being used, and ASAN is enabled, we need to set the debugger environment
# so that it behaves well with MSVC's debugger, and we can run the target from visual studio
if(MSVC)
  get_all_targets(all_targets)
  set_target_properties(${all_targets} PROPERTIES VS_DEBUGGER_ENVIRONMENT "PATH=$(VC_ExecutablePath_x64);%PATH%")
endif()