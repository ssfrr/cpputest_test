cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

project("CppUTest Example")
enable_testing()
string(ASCII 27 Esc)
set(Red        "${Esc}[31m")
set(Green      "${Esc}[32m")
set(Yellow     "${Esc}[33m")
set(ColorReset "${Esc}[m")


# these can be set via ccmake or the CMake GUI to use a custom path for
# CppUTest
find_library(CPPUTEST_LIB
    CppUTest)
find_path(CPPUTEST_INC
    CppUTest/CommandLineTestRunner.h)

find_program(LCOV_EXE lcov)

# Listing all the source files individually has the benefit that adding a
# sourcefile updates CMakeLists.txt (this file) and so the next time we run
# "make" it will re-run cmake automatically to do all it's internal bookkeeping
add_executable(Run
    src/Main.c
    src/Adder.c)

if(CPPUTEST_LIB AND CPPUTEST_INC)
    include_directories(${CPPUTEST_INC})
    add_executable(RunTests
        src/Adder.c
        test/TestRunner.cpp)
    target_link_libraries(RunTests
        ${CPPUTEST_LIB})
    set_target_properties(RunTests
        PROPERTIES
        COMPILE_FLAGS "--coverage -g -O0"
        LINK_FLAGS --coverage)
    if(LCOV_EXE)
        add_custom_target(coverage
            DEPENDS RunTests
            COMMAND echo "Initializing coverage data files..."
            COMMAND ${LCOV_EXE} --quiet --directory . --zerocounters # delete any existing .gcda files
            COMMAND ${LCOV_EXE} --quiet --directory . --base-directory . --capture --initial -o cov_init.info # generate initial data before the run
            COMMAND echo "Running the tests..."
            COMMAND ${CMAKE_CTEST_COMMAND} # run the tests
            COMMAND echo "Generating coverage data..."
            COMMAND ${LCOV_EXE} --quiet --directory . --base-directory . --capture -o cov_run.info # collect the coverage data
            COMMAND ${LCOV_EXE} --quiet --add-tracefile cov_init.info --add-tracefile cov_run.info -o cov_total.info # combine the coverate data
            COMMAND ${LCOV_EXE} --list cov_total.info
            VERBATIM)
    else(LCOV_EXE)
        message(WARNING "${Yellow}lcov not found. Coverage stats not available${ColorReset}")
    endif(LCOV_EXE)
else(CPPUTEST_LIB AND CPPUTEST_INC)
    message(WARNING "${Yellow}CppUTest library not found. Not building tests${ColorReset}")
endif(CPPUTEST_LIB AND CPPUTEST_INC)

add_test(Main RunTests)
