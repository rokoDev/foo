message(STATUS "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
message(STATUS "CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CMAKE_CXX_COMPILER_FRONTEND_VARIANT: ${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}")

list(APPEND UNIX_BUILD_TYPES_CLANG_FLAGS
  "-std=c++17"
  "-Werror"
  "-pedantic-errors"
  "-Wall"
  "-Wextra"
  "-Wconversion"
  "-Wsign-conversion"
  "-Wshadow-all"
  "-Wunreachable-code"
  "-Wuninitialized"
  "-Wold-style-cast"
  "-Wfloat-equal"
  "-Wcast-align"
  "-Winvalid-constexpr"
  )

list(APPEND WIN_BUILD_TYPES_CLANG_FLAGS
  "/std:c++17"
  "/WX"
  "/permissive-"
  "/W4"
  )

# Choose c++ compiler flags based on the compiler available or exit with error if no known compiler
if(CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  if("${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "MSVC")
    list(APPEND ALL_CXX_FLAGS "${WIN_BUILD_TYPES_CLANG_FLAGS}")
  elseif("${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "GNU")
    list(APPEND ALL_CXX_FLAGS "${UNIX_BUILD_TYPES_CLANG_FLAGS}")
  else()
    message(FATAL_ERROR "CMAKE_CXX_COMPILER_FRONTEND_VARIANT: ${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}(Unrecognized)")
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL AppleClang)
  list(APPEND ALL_CXX_FLAGS "${UNIX_BUILD_TYPES_CLANG_FLAGS}")# "${CMAKE_CXX_FLAGS}"
else()
  message(FATAL_ERROR "CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}(Unrecognized)")
endif()

message(STATUS "ALL_CXX_FLAGS: ${ALL_CXX_FLAGS}")

target_sources(foo
	PRIVATE
    include/foo/file_1.h

    src/file_1.cpp
  )

set(MAIN_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)

set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

FetchContent_GetProperties(curl)
if(NOT curl_POPULATED)
  FetchContent_Populate(curl)
  message(STATUS "CURL_IS_POPULATED")
  set(ARCH x86_64)
  set(SDK macosx)
  set(DEPLOYMENT_TARGET 10.8)
  execute_process(
    COMMAND zsh -c "${CMAKE_CURRENT_SOURCE_DIR}/build_curl_macos.sh ${curl_SOURCE_DIR} ${ARCH} ${SDK} ${DEPLOYMENT_TARGET}"
    RESULT_VARIABLE result
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY ${curl_SOURCE_DIR}
  )

  if(result)
    message(FATAL_ERROR "Failed to build curl lib: ${result}")
  endif()
endif()

add_library(mylibcurl STATIC IMPORTED)
set_target_properties(mylibcurl PROPERTIES IMPORTED_LOCATION ${curl_SOURCE_DIR}/artifacts/lib/libcurl.a)
target_include_directories(mylibcurl INTERFACE ${curl_SOURCE_DIR}/artifacts/include)
set_target_properties(mylibcurl PROPERTIES FOLDER deps)

target_compile_definitions(foo PRIVATE $<UPPER_CASE:$<CONFIG>>)
target_compile_options(foo PRIVATE ${ALL_CXX_FLAGS} ${ALL_C_FLAGS})
set_property(TARGET foo APPEND PROPERTY SRC_DIRS "${CMAKE_CURRENT_LIST_DIR}/include" "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_link_libraries(foo PUBLIC mylibcurl tinyxml2)
target_include_directories(foo PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
  # ${curl_SOURCE_DIR}/artifacts/include
)