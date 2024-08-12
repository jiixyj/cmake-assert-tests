# Given a path to a test .cpp, returns a unique CMake target name, the test
# type, and the name of the test (without test type).
#
# Example (co-located tests for "testlib/add.{h,cpp}" in a folder
# "testlib/add.test"):
#
#   testlib/add.test/constructor.compile.pass.cpp:
#   - TARGET: testlib.add-constructor-compile.pass
#   - TYPE:   compile.pass
#   - NAME:   testlib.add:constructor
#
# In this mode, the tests are assumed to live in a folder with the suffix
# ".test".
#
# In the test name, the part before the colon refers to the unit/module under
# test. The part after the colon refers to the test file and may contain
# forward slashes.
#
# When given the SEPARATED_PLACEMENT option, a different algorithm is used that
# is more appropriate for separated test placement (e.g. tests living in a
# "tests" folder in the repository root).
#
# Example ("testlib/add/add.pass.cpp" test in top level folder "tests"):
#
#   testlib/add/add.pass.cpp:
#   - TARGET: testlib-add-add-pass
#   - TYPE:   pass
#   - NAME:   testlib/add/add
#
# Here, the name is the whole path to the test file, but without the test type.
#
function(test_helpers_get_assert_test_info _path)
    cmake_parse_arguments(
        PARSE_ARGV
        1
        ""
        "SEPARATED_PLACEMENT"
        "TARGET;TYPE;NAME"
        ""
    )

    string(LENGTH "${_path}" _path_length)

    if(_path MATCHES ".compile.pass.cpp$")
        math(EXPR _index "${_path_length} - 17")
        set(_type "compile.pass")
    elseif(_path MATCHES ".compile.fail.cpp$")
        math(EXPR _index "${_path_length} - 17")
        set(_type "compile.fail")
    elseif(_path MATCHES ".verify.cpp$")
        math(EXPR _index "${_path_length} - 11")
        set(_type "verify")
    elseif(_path MATCHES ".pass.cpp$")
        math(EXPR _index "${_path_length} - 9")
        set(_type "pass")
    else()
        message(FATAL_ERROR "unknown type of test '${_path}'")
    endif()

    string(SUBSTRING "${_path}" 0 ${_index} _name)

    if(_SEPARATED_PLACEMENT)
        string(REGEX REPLACE "/" "-" _target "${_name}-${_type}")
    else()
        string(FIND "${_name}" ".test/" _index)
        string(SUBSTRING "${_name}" 0 ${_index} _component)
        string(REGEX REPLACE "/" "." _component "${_component}")

        math(EXPR _index "${_index} + 6")
        string(SUBSTRING "${_name}" ${_index} -1 _name)

        string(REGEX REPLACE "/" "-" _target "${_component}-${_name}-${_type}")
        string(PREPEND _name "${_component}:")
    endif()

    if(_TARGET)
        set(${_TARGET} "${_target}" PARENT_SCOPE)
    endif()
    if(_TYPE)
        set(${_TYPE} "${_type}" PARENT_SCOPE)
    endif()
    if(_NAME)
        set(${_NAME} "${_name}" PARENT_SCOPE)
    endif()
endfunction()

# Adds a "libc++ style" `assert()` based test to the build.
#
# "TARGET" must refer to an existing CMake target for a test executable.
#
# The "TYPE" parameter must be one of "pass", "compile.pass", "compile.fail" or
# "verify". "verify" works only for Clang. On other compilers, "verify" tests
# are disabled with the "DISABLED" test property.
#
# "NAME" will be the name of a newly created CTest test.
#
# Any `NDEBUG` define is automatically disabled for any test added by this
# function.
#
function(test_helpers_add_assert_test)
    cmake_parse_arguments(PARSE_ARGV 0 "" "" "TARGET;TYPE;NAME" "")

    # Get rid of NDEBUG define which is set by CMake by default in some build
    # modes. Do it with a forced include to avoid compiler warnings about
    # undefining defines (-DNDEBUG followed by -UNDEBUG).
    target_include_directories(
        ${_TARGET}
        SYSTEM
        PRIVATE "${CMAKE_CURRENT_FUNCTION_LIST_DIR}"
    )
    if(MSVC)
        target_compile_options(${_TARGET} PRIVATE /FIundef_ndebug.h)
    else()
        target_compile_options(${_TARGET} PRIVATE -include undef_ndebug.h)
    endif()

    string(APPEND _NAME ".${_TYPE}")

    if(_TYPE STREQUAL "pass")
        add_test(NAME ${_NAME} COMMAND ${_TARGET})
    elseif(
        _TYPE STREQUAL "verify"
        OR _TYPE STREQUAL "compile.pass"
        OR _TYPE STREQUAL "compile.fail"
    )
        if(MSVC)
            set(_extra_options "/Zs")
        else()
            set(_extra_options "-fsyntax-only")
        endif()
        if(_TYPE STREQUAL "verify")
            list(APPEND _extra_options "SHELL:-Xclang -verify")
        endif()
        target_compile_options(${_TARGET} PRIVATE ${_extra_options})

        set_target_properties(
            ${_TARGET}
            PROPERTIES
                CXX_LINKER_LAUNCHER "${CMAKE_COMMAND};-E;true"
                EXCLUDE_FROM_ALL TRUE
                EXCLUDE_FROM_DEFAULT_BUILD TRUE
        )

        add_test(
            NAME ${_NAME}
            COMMAND
                ${CMAKE_COMMAND} --build . --target ${_TARGET} --verbose
                --config $<CONFIG>
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )

        if(_TYPE STREQUAL "compile.fail")
            set_tests_properties(${_NAME} PROPERTIES WILL_FAIL true)
        endif()

        if(
            _TYPE STREQUAL "verify"
            AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
        )
            set_tests_properties(${_NAME} PROPERTIES DISABLED TRUE)
        endif()
    else()
        message(FATAL_ERROR "unknown test type '${_TYPE}'")
    endif()
endfunction()

macro(_test_helpers_forward_bool_flag _flag)
    if(_${_flag})
        set(_${_flag} ${_flag})
    else()
        set(_${_flag})
    endif()
endmacro()

# Given a path to a test .cpp file adds a CMake executable target and registers
# it as a CTest test. The behavior of the test depends on the suffix of the
# path, which may be one of ".pass.cpp", ".compile.pass.cpp",
# ".compile.fail.cpp" or ".verify.cpp".
#
# When the "SEPARATED_PLACEMENT" flag is given, the test name
# will be appropriate for separated test placement (e.g. in a top level "tests"
# folder). Otherwise, the tests are assumed to be co-located with the
# source/header of the unit under test.
#
# Libraries in "LIBRARIES" are privately linked to the executable with
# `target_link_libraries()`.
#
# Compiler options in "OPTIONS" are privately applied to the executable with
# `target_compile_options()`.
function(test_helpers_add_simple_assert_test _path)
    cmake_parse_arguments(
        PARSE_ARGV
        1
        ""
        "SEPARATED_PLACEMENT"
        ""
        "LIBRARIES;OPTIONS"
    )

    _test_helpers_forward_bool_flag(SEPARATED_PLACEMENT)

    test_helpers_get_assert_test_info("${_path}" NAME _test_name TARGET _target TYPE _type ${_SEPARATED_PLACEMENT})
    add_executable(${_target} "${_path}")
    test_helpers_add_assert_test(NAME "${_test_name}" TARGET "${_target}" TYPE "${_type}")
    target_link_libraries(${_target} PRIVATE ${_LIBRARIES})
    target_compile_options(${_target} PRIVATE ${_OPTIONS})
endfunction()

# Globs for tests. Places the resulting list into the first argument. Use the
# "SEPARATED_PLACEMENT" option when doing separated test placement.
function(test_helpers_glob_for_tests _result)
    cmake_parse_arguments(PARSE_ARGV 1 "" "SEPARATED_PLACEMENT" "" "")

    if(_SEPARATED_PLACEMENT)
        set(_pattern "*.cpp" "*/*.cpp")
    else()
        set(_pattern
            "*.test/*.cpp"
            "*.test/*/*.cpp"
            "*/*.test/*.cpp"
            "*/*.test/*/*.cpp"
        )
    endif()

    file(
        GLOB_RECURSE _tests
        LIST_DIRECTORIES false
        RELATIVE "${CMAKE_CURRENT_LIST_DIR}"
        CONFIGURE_DEPENDS
        ${_pattern}
    )

    set(${_result} "${_tests}" PARENT_SCOPE)
endfunction()
