include_guard()

function(fetch_googletest target_project)
   if(NOT googletest_POPULATED)
      message(STATUS "Pulling Google Test into ${target_project}...")
      FetchContent_Declare(
         googletest
         GIT_REPOSITORY https://github.com/google/googletest.git
         GIT_TAG        release-1.11.0
      )
      message(STATUS "Making Google Test available...")
      FetchContent_MakeAvailable(googletest)

      message(STATUS "Google Test Added!")
   endif()
endfunction()
