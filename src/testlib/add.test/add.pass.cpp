#include <assert.h>

#include <testlib/add.h>

static void test_add() { assert(testlib::add(4, 5) == 9); }

int main() {
  test_add();
  return 0;
}
