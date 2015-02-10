cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

project("CppUTest Example")
enable_testing()
string(ASCII 27 Esc)
set(Red        "${Esc}[31m")
set(Green      "${Esc}[32m")
set(Yellow     "${Esc}[33m")
set(ColorReset "${Esc}[m")

set(CPPUTEST_BASEDIR "/Users/srussell/local/src/cpputest")
include_directories("${CPPUTEST_BASEDIR}/include")

find_library(CPPUTEST_LIB
    CppUTest
    "${CPPUTEST_BASEDIR}/cpputest_build/src/CppUTest")

# Listing all the source files individually has the benefit that adding a
# sourcefile updates CMakeLists.txt (this file) and so the next time we run
# "make" it will re-run cmake automatically to do all it's internal bookkeeping
add_executable(Run
    src/Main.c
    src/Adder.c)
if(CPPUTEST_LIB)
    add_executable(RunTests
        src/Adder.c
        test/TestRunner.cpp)
    target_link_libraries(RunTests
        ${CPPUTEST_LIB})
    set_target_properties(RunTests
        PROPERTIES
        COMPILE_FLAGS "-fprofile-arcs -ftest-coverage -g -O0"
        # warning - this flag needs to be -lgcov instead of --coverage for gcc
        LINK_FLAGS --coverage)
else(CPPUTEST_LIB)
    message(WARNING "${Yellow}CppUTest library not found. Not building tests${ColorReset}")
endif(CPPUTEST_LIB)

#add_test(RunTests)
