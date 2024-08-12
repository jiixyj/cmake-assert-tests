#ifndef TESTLIB_ADD_H
#define TESTLIB_ADD_H

namespace testlib {

inline constexpr struct add_t {
  explicit add_t() = default;
  int operator()(int a, int b) const;
} add{};

constexpr int constexpr_add(int a, int b) { return a + b; }

} // namespace testlib

#endif
