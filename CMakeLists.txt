# Advance Wars: builds the C that gbarecomp generates from your ROM into gen/.
# build.cmd runs both steps (translate, then this); gen/ is never committed.
# A build farm sends the checkout with gen/ already in it and builds here.
cmake_minimum_required(VERSION 3.16)
project(advancewars C)

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/gen/CMakeLists.txt")
    message(FATAL_ERROR "gen/ is empty: run build.cmd first (it translates game/aw.gba)")
endif()

if(UNIX AND NOT APPLE)
    find_package(SDL2 CONFIG QUIET)
    if(TARGET SDL2::SDL2 AND NOT TARGET SDL2::SDL2main)
        add_library(SDL2::SDL2main INTERFACE IMPORTED)
    endif()
endif()

# AWRE.exe lands in build/<config>/ rather than build/gen/<config>/
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
add_subdirectory(gen)

if(UNIX AND NOT APPLE)
    target_link_libraries(AWRE PRIVATE m)
    target_link_options(AWRE PRIVATE -Wl,-z,stack-size=16777216)
endif()
