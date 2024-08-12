cmake_minimum_required(VERSION 3.23)
project(testlib LANGUAGES CXX)

#

include(CTest)

#

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

#

add_subdirectory(src)

#

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

#

if(PROJECT_IS_TOP_LEVEL)
    macro(setup_install_dirs _project_name)
        include(GNUInstallDirs)

        set(CMAKE_INSTALL_CMAKECONFDIR
            "${CMAKE_INSTALL_LIBDIR}/cmake/${_project_name}"
            CACHE PATH
            "Installation directory for CMake config (.cmake) files"
        )
        mark_as_advanced(CMAKE_INSTALL_CMAKECONFDIR)
    endmacro()

    setup_install_dirs("${PROJECT_NAME}")

    install(TARGETS testlib EXPORT ${PROJECT_NAME}-targets FILE_SET HEADERS)
    install(
        EXPORT ${PROJECT_NAME}-targets
        DESTINATION "${CMAKE_INSTALL_CMAKECONFDIR}"
        NAMESPACE "${PROJECT_NAME}::"
    )

    file(
        WRITE
        "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}-targets.cmake\")
"
    )
    install(
        FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
        DESTINATION "${CMAKE_INSTALL_CMAKECONFDIR}"
    )
endif()
