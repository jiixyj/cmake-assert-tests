#include <testlib.h>

int main() {
  {
    // <testlib/add.h>
    using testlib::add;
    using testlib::constexpr_add;
  }

  {
    // <testlib/fibonacci.h>
    using testlib::fibonacci;
  }
}
