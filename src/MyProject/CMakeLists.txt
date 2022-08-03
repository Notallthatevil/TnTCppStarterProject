file(GLOB_RECURSE MyProject_Src
  CONFIGURE_DEPENDS "*.cpp" "*.h" "*.ixx"
)

if(MSVC)
   add_compile_options(/bigobj)
endif()

add_executable(MyProject ${MyProject_Src})
target_include_directories(MyProject PRIVATE 
   ${CMAKE_CURRENT_SOURCE_DIR}
)
target_link_libraries(MyProject PRIVATE project_warnings project_options project_dependencies)

set_build_output_dirs(MyProject)

enable_sanitizers(MyProject TRUE FALSE FALSE FALSE FALSE)
