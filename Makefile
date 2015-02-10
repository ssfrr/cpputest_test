SRCDIR:=src
TESTDIR:=test
MAIN_SRC:=${SRCDIR}/Main.c
MAIN_OBJ:=${MAIN_SRC:.c=.o}
SOURCES:=${filter-out ${MAIN_SRC}, ${wildcard ${SRCDIR}/*.c}}
OBJECTS:=${SOURCES:.c=.o}
MAIN_EXE=${notdir ${MAIN_OBJ:.o=}}

TESTRUNNER_EXE=TestRunner
CPPUTEST_BASEDIR:=${HOME}/local/src/cpputest
CPPUTEST_INCDIR:=${CPPUTEST_BASEDIR}/include
TEST_SOURCES:=${wildcard ${TESTDIR}/*.cpp}
COV_FILES:=${SOURCES:.c=.gcda} ${SOURCES:.c=.gcno} ${TEST_SOURCES:.cpp=.gcno} ${TEST_SOURCES:.cpp=.gcda}
TEST_OBJECTS:=${TEST_SOURCES:.cpp=.o}
TEST_LD_LIBRARIES:=-L$(CPPUTEST_BASEDIR)/cpputest_build/src/CppUTest -lCppUTest
CPPFLAGS:=-I${CPPUTEST_INCDIR}
CPPFLAGS+=-fprofile-arcs -ftest-coverage
CXXFLAGS+=-include $(CPPUTEST_BASEDIR)/include/CppUTest/MemoryLeakDetectorNewMacros.h
CFLAGS+=-include $(CPPUTEST_BASEDIR)/include/CppUTest/MemoryLeakDetectorMallocMacros.h

ifeq ($(COMPILER_NAME),$(CLANG_STR))
	LDFLAGS += --coverage
else
	LDFLAGS += -lgcov
endif


default: ${MAIN_EXE}

clean:
	rm -f \
		${OBJECTS} \
		${MAIN_EXE} \
		${MAIN_OBJ} \
		${TEST_OBJECTS} \
		${TESTRUNNER_EXE} \
		${COV_FILES}

test: ${TESTRUNNER_EXE}
	./${TESTRUNNER_EXE}

${TESTRUNNER_EXE}: ${OBJECTS} ${TEST_OBJECTS}
	${CXX} ${LDFLAGS} ${TEST_LD_LIBRARIES} -o $@ $^

${MAIN_EXE}: ${MAIN_OBJ} ${OBJECTS}
