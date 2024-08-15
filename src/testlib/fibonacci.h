#ifndef TESTLIB_FIBONACCI_H
#define TESTLIB_FIBONACCI_H

#include <cstdint>

namespace testlib {

// Returns Fibonacci numbers as defined in <https://oeis.org/A000045>,
// modulo 2^64.
// Valid for n >= 0.
// This is too slow for real world use, but serves as a simple example of
// `constexpr` code where the compiler's evaluation step limit needs to be
// raised.
constexpr std::uint64_t fibonacci(int n) {
  if (n <= 1) {
    return static_cast<std::uint64_t>(n);
  }
  return testlib::fibonacci(n - 1) + testlib::fibonacci(n - 2);
}

} // namespace testlib

#endif
