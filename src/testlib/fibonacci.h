#ifndef TESTLIB_FIBONACCI_H
#define TESTLIB_FIBONACCI_H

#include <cstdint>

namespace testlib {

constexpr std::uint64_t fibonacci(int n) {
  if (n <= 2) {
    return 1;
  }
  return testlib::fibonacci(n - 1) + testlib::fibonacci(n - 2);
}

} // namespace testlib

#endif
