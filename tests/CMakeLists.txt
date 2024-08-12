include(TestHelpers)

test_helpers_glob_for_tests(_tests SEPARATED_PLACEMENT)
foreach(_test IN LISTS _tests)
    test_helpers_add_simple_assert_test("${_test}" SEPARATED_PLACEMENT
        LIBRARIES testlib::testlib
    )
endforeach()
