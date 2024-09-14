cmake_minimum_required(VERSION 3.25...3.30)

# Only set the cxx_standard if it is not set by someone else
if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 20)
endif()

# strongly encouraged to enable this globally to avoid conflicts between -Wpedantic being enabled
# and -std=c++20 and -std=gnu++20 for example when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS OFF)

project(
  Hello
  VERSION 0.0.1
  LANGUAGES CXX
)

include(cmake/CPM.cmake)

option(FMT_INSTALL "create an installable target" YES)
# A git package with both version 10.1 and a tag provided
# XXX CPMAddPackage("gh:fmtlib/fmt@10.1#10.1.1")
# FIXME: EXCLUDE_FROM_ALL must be OFF or fmt target will NOT be installed! CK

# NOTE: The fmt library has to be installed if not found!
# BUT either clang-tidy checks nor compiler warnings are wanted!
CPMFindPackage(
  NAME fmt
  GIT_TAG 11.0.2
  VERSION 11.0
  GITHUB_REPOSITORY fmtlib/fmt
  EXCLUDE_FROM_ALL OFF
  SYSTEM YES
)

if(NOT BUILD_SHARED_LIBS AND LINUX)
  set(CMAKE_EXE_LINKER_FLAGS -static)
endif()

find_package(XercesC 3.2.5 REQUIRED)
add_executable(EnumVal EnumVal.cpp)
target_link_libraries(EnumVal PRIVATE XercesC::XercesC)

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} fmt::fmt)

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

set(_targets ${PROJECT_NAME} EnumVal)
foreach(_EXE IN LISTS _targets)
  message(STATUS "Install TARGET ${_EXE}")
  install(TARGETS ${_EXE} RUNTIME)

  if(BUILD_SHARED_LIBS)
    install(IMPORTED_RUNTIME_ARTIFACTS ${_EXE} RUNTIME_DEPENDENCY_SET ${_EXE}_dependency_set)

    # NOTE: POST_EXCLUDE_REGEXES to prevent use of: CONFLICTING_DEPENDENCIES_PREFIX  _conflicts
    # cmake-format: off
    install(
      RUNTIME_DEPENDENCY_SET ${_EXE}_dependency_set
      POST_EXCLUDE_REGEXES "${CMAKE_INSTALL_PREFIX}/lib"
      RUNTIME DESTINATION lib
    )
    # cmake-format: on
  endif()
endforeach()

include(CPack)
