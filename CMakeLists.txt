cmake_minimum_required(VERSION 3.21...3.27)

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
if(NOT FMT_INSTALL)
  find_package(fmt REQUIRED)
else()
  # A git package with both version and tag provided FIXME: EXCLUDE_FROM_ALL must be OFF or fmt target
  # will NOT be installed! CK XXX CPMAddPackage("gh:fmtlib/fmt@10.1.1#10.1.1")

  # NOTE: The fmt library has to be installed if not found! BUT either clang-tidy checks nor compiler
  # warnings are wanted!
  CPMAddPackage(
    NAME fmt
    GIT_TAG 10.1.1
    GITHUB_REPOSITORY fmtlib/fmt
    EXCLUDE_FROM_ALL OFF
    SYSTEM YES # used in case of cmake v3.25
  )
endif()

if(LINUX)
  # XXX set(CMAKE_EXE_LINKER_FLAGS -static)
endif()

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} fmt::fmt)

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

install(TARGETS ${PROJECT_NAME} RUNTIME COMPONENT ${PROJECT_NAME})
if(NOT FMT_INSTALL)
  install(IMPORTED_RUNTIME_ARTIFACTS fmt::fmt RUNTIME_DEPENDENCY_SET runtime_dependency_set RUNTIME)
  install(RUNTIME_DEPENDENCY_SET runtime_dependency_set RUNTIME DESTINATION lib)
endif()

if(LINUX)
  # set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS "/lib/x86_64-linux-gnu/libstdc++.so.6")
endif()
if(MSVC OR LINUX)
  include(InstallRequiredSystemLibraries)
endif()

include(CPack)
