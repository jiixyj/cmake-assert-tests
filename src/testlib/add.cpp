#include <testlib/add.h>

namespace testlib {

int add_t::operator()(int a, int b) const { return a + b; }

} // namespace testlib
