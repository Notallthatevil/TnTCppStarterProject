file(GLOB_RECURSE CppStarterProject_Tests_Src
  CONFIGURE_DEPENDS "*.cpp" "*.h" "*.ixx"
)

add_executable(CppStarterProject_Tests ${CppStarterProject_Tests_Src})
target_include_directories(CppStarterProject_Tests PRIVATE 
   ${CMAKE_CURRENT_SOURCE_DIR}
)
fetch_googletest(CppStarterProject_Tests)
include(GoogleTest)

target_link_libraries(CppStarterProject_Tests PRIVATE project_warnings project_options project_dependencies gtest gmock)

target_compile_definitions(CppStarterProject_Tests PRIVATE TNT_TESTS_ASSETS_DIR="${CMAKE_CURRENT_SOURCE_DIR}/Assets")

if(MSVC)
   add_compile_options(/bigobj)
   # Disable Potential comparison of a constant with another constant
   target_compile_options(CppStarterProject_Tests PRIVATE /wd6326 /wd28196)
endif()

set_build_output_dirs(CppStarterProject_Tests)


enable_sanitizers(CppStarterProject_Tests TRUE FALSE FALSE FALSE FALSE)

gtest_discover_tests(
   CppStarterProject_Tests
   TEST_PREFIX
   "unittests."
   REPORTER
   xml
   OUTPUT_DIR
   .
   OUTPUT_PREFIX
   "unittests."
   OUTPUT_SUFFIX
   .xml
)
