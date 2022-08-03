file(GLOB_RECURSE RuntimeTesting_Src
  CONFIGURE_DEPENDS "*.cpp" "*.h" "*.ixx"
)

if(MSVC)
   add_compile_options(/bigobj)
endif()


add_executable(RuntimeTesting ${RuntimeTesting_Src})
target_include_directories(RuntimeTesting PRIVATE 
   ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(RuntimeTesting PRIVATE project_warnings project_options project_dependencies)

set_build_output_dirs(RuntimeTesting)

enable_sanitizers(RuntimeTesting TRUE FALSE FALSE FALSE FALSE)
