#include <testlib/add.h>

int main() {
  testlib::add_t add = {};
  // expected-error@-1 {{chosen constructor is explicit in copy-initialization}}
  // expected-note@testlib/add.h:* {{explicit constructor declared here}}
  return 0;
}
