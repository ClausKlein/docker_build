cmake_minimum_required(VERSION 3.25...3.28)

# Only set the cxx_standard if it is not set by someone else
if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()

# strongly encouraged to enable this globally to avoid conflicts between -Wpedantic being enabled
# and -std=c++20 and -std=gnu++20 for example when compiling with PCH enabled
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(
  Hello
  VERSION 0.0.1
  LANGUAGES CXX
)

include(cmake/CPM.cmake)

enable_testing()

option(FMT_INSTALL "create an installable target" YES)
# A git package with both version 10.2 and a tag provided
# XXX CPMAddPackage("gh:fmtlib/fmt@10.1#10.2.1")
# FIXME: EXCLUDE_FROM_ALL must be OFF or fmt target will NOT be installed! CK

# NOTE: The fmt library has to be installed if not found!
# BUT either clang-tidy checks nor compiler warnings are wanted!
CPMAddPackage(
  NAME fmt
  GIT_TAG 10.2.1
  VERSION 10.2
  GITHUB_REPOSITORY fmtlib/fmt
  EXCLUDE_FROM_ALL OFF
  SYSTEM YES # used in case of cmake v3.25
)

# NOTE: only possible if all dependens libs are static!
# if(NOT BUILD_SHARED_LIBS AND LINUX)
#   set(CMAKE_EXE_LINKER_FLAGS -static)
# endif()

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} fmt::fmt)
add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

install(TARGETS ${PROJECT_NAME} RUNTIME COMPONENT ${PROJECT_NAME})

if(BUILD_SHARED_LIBS)
  install(IMPORTED_RUNTIME_ARTIFACTS ${PROJECT_NAME} RUNTIME_DEPENDENCY_SET _dependency_set)

  # NOTE: POST_EXCLUDE_REGEXES to prevent use of: CONFLICTING_DEPENDENCIES_PREFIX  _conflicts
  # cmake-format: off
  install(
    RUNTIME_DEPENDENCY_SET _dependency_set
    POST_EXCLUDE_REGEXES "${CMAKE_INSTALL_PREFIX}/lib"
    RUNTIME DESTINATION lib
  )
  # cmake-format: on
endif()

include(CPack)
