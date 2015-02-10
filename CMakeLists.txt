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
        COMPILE_FLAGS "--coverage -g -O0"
        LINK_FLAGS --coverage)
    add_custom_target(coverage
        DEPENDS RunTests
        COMMAND lcov --quiet --directory . --zerocounters # delete any existing .gcda files
        COMMAND lcov --quiet --directory . --base-directory . --capture -i -o cov_init.info # generate initial data before the run
        COMMAND ./RunTests # run the tests
        COMMAND lcov --quiet --directory . --base-directory . --capture -o cov_run.info # collect the coverage data
        COMMAND lcov --quiet --add-tracefile cov_init.info --add-tracefile cov_run.info -o cov_total.info # combine the coverate data
        COMMAND lcov --list cov_total.info
        VERBATIM)
else(CPPUTEST_LIB)
    message(WARNING "${Yellow}CppUTest library not found. Not building tests${ColorReset}")
endif(CPPUTEST_LIB)

#add_test(RunTests)
