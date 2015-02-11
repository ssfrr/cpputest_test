cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

project("CppUTest Example")
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
    set(TEST_RUNNER RunTests)
    include_directories(
        ${CPPUTEST_INC}
        src
        test)
    # Add all the sources necessary for the test build here
    add_executable(${TEST_RUNNER}
        src/Adder.c
        test/TestCore.cpp
        test/TestRunner.cpp)
    target_link_libraries(${TEST_RUNNER}
        ${CPPUTEST_LIB})
    set_target_properties(${TEST_RUNNER}
        PROPERTIES
        COMPILE_FLAGS "--coverage -g -O0"
        LINK_FLAGS --coverage)
    add_custom_target(test
        DEPENDS ${TEST_RUNNER}
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${TEST_RUNNER})

    if(LCOV_EXE)
        set(OBJECT_DIR "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${TEST_RUNNER}.dir/src")
        add_custom_target(coverage
            DEPENDS ${TEST_RUNNER}
            COMMAND echo "Initializing coverage data files..."
            COMMAND ${LCOV_EXE} --quiet --directory ${OBJECT_DIR} --zerocounters # delete any existing .gcda files
            COMMAND ${LCOV_EXE} --quiet --directory ${OBJECT_DIR} --base-directory ${OBJECT_DIR} --capture --initial -o cov_init.info # generate initial data before the run
            COMMAND echo "Running the tests..."
            COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${TEST_RUNNER}
            COMMAND echo "Generating coverage data..."
            COMMAND ${LCOV_EXE} --quiet --directory ${OBJECT_DIR} --base-directory ${OBJECT_DIR} --capture -o cov_run.info # collect the coverage data
            COMMAND ${LCOV_EXE} --quiet --add-tracefile cov_init.info --add-tracefile cov_run.info -o cov_total.info # combine the coverate data
            COMMAND ${LCOV_EXE} --list cov_total.info
            COMMAND rm -f cov_init.info cov_run.info cov_total.info
            COMMAND find ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY} -name *.gcda -delete
            VERBATIM)
    else(LCOV_EXE)
        message(WARNING "${Yellow}lcov not found. Coverage stats not available${ColorReset}")
    endif(LCOV_EXE)
else(CPPUTEST_LIB AND CPPUTEST_INC)
    message(WARNING "${Yellow}CppUTest library not found. Not building tests${ColorReset}")
endif(CPPUTEST_LIB AND CPPUTEST_INC)

