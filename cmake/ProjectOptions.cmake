include_guard()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


function(set_build_output_dirs project_name)
   set_target_properties(${project_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})   
   set_target_properties(${project_name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
   set_target_properties(${project_name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
endfunction()


# Generate compile_commands.json to make it easier to work with clang based tools
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

option(ENABLE_CACHE "Enable CCache if available" OFF)
option(ProjectOptions_ENABLE_PCH "Enables pch generation" OFF)
###################################################################################################
# Enable Cache if on
###################################################################################################
if(ENABLE_CACHE)
   set(CACHE_OPTION "ccache" CACHE STRING "Compiler cache to be used")
   set(CACHE_OPTION_VALUES "ccache" "sccache")
   set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})
   
   list(
      FIND
      CACHE_OPTION_VALUES
      ${CACHE_OPTION}
      CACHE_OPTION_INDEX
   )
   
   if(${CACHE_OPTION_INDEX} EQUAL -1)
     message(STATUS "Using custom compiler cache system: '${CACHE_OPTION}', explicitly supported entries are ${CACHE_OPTION_VALUES}")
   endif()
   
   find_program(CACHE_BINARY NAMES ${CACHE_OPTION_VALUES})
   if(CACHE_BINARY)
      message(STATUS "${CACHE_BINARY} found and enabled")
      set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY} CACHE FILEPATH "CXX compiler cache used")
      set(CMAKE_C_COMPILER_LAUNCHER ${CACHE_BINARY} CACHE FILEPATH "C compiler cache used")
   else()
      message(WARNING "${CACHE_OPTION} is enabled but was not found. Not using it")
   endif()
endif()

###################################################################################################
# Set a default build type if none was specified
###################################################################################################
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
  set(
     CMAKE_BUILD_TYPE
     RelWithDebInfo
     CACHE STRING "Choose the type of build." FORCE
  )
  # Set the possible values of build type for cmake-gui, ccmake
  set_property(
    CACHE CMAKE_BUILD_TYPE
    PROPERTY STRINGS
             "Debug"
             "Release"
             "MinSizeRel"
             "RelWithDebInfo"
  )
endif()

###################################################################################################
# Generate compile_commands.json to make it easier to work with clang based tools
###################################################################################################
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

###################################################################################################
# Enhance error reporting and compiler messages
###################################################################################################
if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  if(WIN32)
    # On Windows cuda nvcc uses cl and not clang
    add_compile_options($<$<COMPILE_LANGUAGE:C>:-fcolor-diagnostics> $<$<COMPILE_LANGUAGE:CXX>:-fcolor-diagnostics>)
  else()
    add_compile_options(-fcolor-diagnostics)
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(WIN32)
    # On Windows cuda nvcc uses cl and not gcc
    add_compile_options($<$<COMPILE_LANGUAGE:C>:-fdiagnostics-color=always>
                        $<$<COMPILE_LANGUAGE:CXX>:-fdiagnostics-color=always>)
  else()
    add_compile_options(-fdiagnostics-color=always)
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND MSVC_VERSION GREATER 1900)
  add_compile_options(/diagnostics:column)
else()
  message(STATUS "No colored compiler diagnostic set for '${CMAKE_CXX_COMPILER_ID}' compiler.")
endif()


include_guard()

include("${ProjectOptions_SRC_DIR}/Utilities.cmake")

###################################################################################################
# Run VCVarsall if on windows.
###################################################################################################
# if MSVC but VSCMD_VER is not set, which means vcvarsall has not run
if(MSVC AND "$ENV{VSCMD_VER}" STREQUAL "")
  # find vcvarsall.bat
   get_filename_component(MSVC_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
   find_file(
      VCVARSALL_FILE 
      NAMES vcvarsall.bat
      PATHS "${MSVC_DIR}"
            "${MSVC_DIR}/.."
            "${MSVC_DIR}/../.."
            "${MSVC_DIR}/../../../../../../../.."
            "${MSVC_DIR}/../../../../../../.."
      PATH_SUFFIXES "VC/Auxiliary/Build" "Common7/Tools" "Tools"
   )

   if(EXISTS ${VCVARSALL_FILE})
      # detect the architecture
      detect_architecture(VCVARSALL_ARCH)

      # run vcvarsall and print the environment variables
      message(STATUS "Running `${VCVARSALL_FILE} ${VCVARSALL_ARCH}` to set up the MSVC environment")
      execute_process(
         COMMAND "cmd" "/c" ${VCVARSALL_FILE} ${VCVARSALL_ARCH} #
                 "&&" "call" "echo" "VCVARSALL_ENV_START" #
                 "&" "set" #
         OUTPUT_VARIABLE VCVARSALL_OUTPUT
         OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      # parse the output and get the environment variables string
      find_substring_by_prefix(VCVARSALL_ENV "VCVARSALL_ENV_START" "${VCVARSALL_OUTPUT}")

      # set the environment variables
      set_env_from_string("${VCVARSALL_ENV}")

   else()
      message(WARNING "Could not find `vcvarsall.bat` for automatic MSVC environment preparation. Please manually open the MSVC command prompt and rebuild the project.")
   endif()
endif()
