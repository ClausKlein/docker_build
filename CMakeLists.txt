cmake_minimum_required(VERSION 3.21...3.27)

project(
  Hello
  VERSION 0.0.1
  LANGUAGES CXX
)

find_package(fmt REQUIRED)

if(LINUX)
  set(CMAKE_EXE_LINKER_FLAGS -static)
endif()

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} fmt::fmt)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
install(IMPORTED_RUNTIME_ARTIFACTS fmt::fmt RUNTIME_DEPENDENCY_SET fmt RUNTIME)
install(RUNTIME_DEPENDENCY_SET fmt RUNTIME DESTINATION lib)

# XXX set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS "/usr/local/opt/fmt/lib/libfmt.10.dylib")
include(InstallRequiredSystemLibraries)

include(CPack)
