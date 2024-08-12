#include <assert.h>

#include <testlib/add.h>

static constexpr bool test_constexpr_add() {
  assert(testlib::constexpr_add(4, 5) == 9);
  return true;
}

int main() {
  test_constexpr_add();
  static_assert(test_constexpr_add());
  return 0;
}
