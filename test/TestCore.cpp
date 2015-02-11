#include <CppUTest/TestHarness.h>

extern "C" {
    #include "Adder.h"
}

TEST_GROUP(AdderTests)
{
};

TEST(AdderTests, SumGivesSum)
{
    LONGS_EQUAL(12, sum(4, 8));
}
