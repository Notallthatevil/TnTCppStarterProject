#define TEST_NAMESPACE MyProjectTests_MyTests
#include "Common/TnTTestsNamespaces.h"

namespace TEST_NAMESPACE {

   NAMESPACE_TEST(MyTest, Test) {
      ASSERT_EQ(2, 1 + 1);
   }

}   // namespace TEST_NAMESPACE
