add_library(testlib testlib/add.cpp)
target_sources(
    testlib
    PUBLIC FILE_SET HEADERS FILES testlib.h testlib/add.h testlib/fibonacci.h
)
target_compile_features(testlib PUBLIC cxx_std_17)
add_library(testlib::testlib ALIAS testlib)

#

add_executable(hello-add main.cpp)
target_link_libraries(hello-add PRIVATE testlib::testlib)

#

if(BUILD_TESTING)
    include(TestHelpers)

    test_helpers_glob_for_tests(_tests)
    foreach(_test IN LISTS _tests)
        test_helpers_add_simple_assert_test("${_test}" LIBRARIES testlib::testlib)
    endforeach()

    # The following demonstrates how to add/change compiler options or other
    # properties of a single test.

    if(MSVC)
        set(_constexpr_steps_flag /constexpr:steps15000000)
    else()
        set(_constexpr_steps_flag -fconstexpr-steps=15000000)
    endif()
    test_helpers_get_assert_test_info(testlib/fibonacci.test/fibonacci.pass.cpp TARGET _target)
    target_compile_options(${_target} PRIVATE "${_constexpr_steps_flag}")
endif()
