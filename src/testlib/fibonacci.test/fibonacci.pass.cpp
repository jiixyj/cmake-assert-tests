#include <assert.h>

#include <testlib/fibonacci.h>

static constexpr bool test_fibonacci() {
  assert(testlib::fibonacci(0) == 0);
  assert(testlib::fibonacci(5) == 5);
  assert(testlib::fibonacci(28) == 317811);
  return true;
}

int main() {
  test_fibonacci();
  static_assert(test_fibonacci());
}
