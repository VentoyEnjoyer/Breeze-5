cmake_minimum_required(VERSION 3.16)
project(Breeze5CleanRoom LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
option(BREEZE_ENABLE_AVX2 "Build for AVX2-capable CPUs" OFF)

add_executable(Breeze5
    src/main.cpp
    src/chess.cpp
    src/eval.cpp
    src/nnue.cpp
    src/search.cpp
    src/uci.cpp
)
target_include_directories(Breeze5 PRIVATE include)
if(MSVC)
    target_compile_options(Breeze5 PRIVATE /W4 /O2)
    if(BREEZE_ENABLE_AVX2)
        target_compile_options(Breeze5 PRIVATE /arch:AVX2)
    endif()
else()
    target_compile_options(Breeze5 PRIVATE -Wall -Wextra -Wpedantic -O3)
    if(BREEZE_ENABLE_AVX2)
        target_compile_options(Breeze5 PRIVATE -mavx2)
    endif()
    find_package(Threads REQUIRED)
    target_link_libraries(Breeze5 PRIVATE Threads::Threads)
endif()

include(CTest)
if(BUILD_TESTING)
    add_executable(Breeze5PerftTests
        tests/perft_test.cpp
        src/chess.cpp
        src/eval.cpp
        src/nnue.cpp
        src/search.cpp
    )
    target_include_directories(Breeze5PerftTests PRIVATE include)
    if(NOT MSVC)
        if(BREEZE_ENABLE_AVX2)
            target_compile_options(Breeze5PerftTests PRIVATE -mavx2)
        endif()
        target_link_libraries(Breeze5PerftTests PRIVATE Threads::Threads)
    endif()
    add_test(NAME perft_and_hash COMMAND Breeze5PerftTests)
endif()
