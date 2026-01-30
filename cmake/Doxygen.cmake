################################################################################
# Doxygen Documentation Configuration
################################################################################
#
# Generates API documentation using Doxygen with optional modern theme.
#
# Usage:
#   include(cmake/Doxygen.cmake)
#   setup_doxygen()
#
################################################################################

function(setup_doxygen)
    find_package(Doxygen OPTIONAL_COMPONENTS dot)
    
    if(NOT DOXYGEN_FOUND)
        message(WARNING "Doxygen requested but not found")
        message(STATUS "Install instructions:")
        message(STATUS "  Ubuntu/Debian: sudo apt-get install doxygen graphviz")
        message(STATUS "  macOS:         brew install doxygen graphviz")
        message(STATUS "  Windows:       choco install doxygen.install graphviz")
        return()
    endif()

    message(STATUS "Found Doxygen: ${DOXYGEN_EXECUTABLE}")
    if(DOXYGEN_DOT_FOUND)
        message(STATUS "Found Graphviz dot: ${DOXYGEN_DOT_EXECUTABLE}")
    endif()

    # Use project README as main page if it exists
    if(NOT DOXYGEN_USE_MDFILE_AS_MAINPAGE AND EXISTS "${PROJECT_SOURCE_DIR}/README.md")
        set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${PROJECT_SOURCE_DIR}/README.md")
    endif()

    # Configure Doxygen output settings
    set(DOXYGEN_QUIET YES)
    set(DOXYGEN_CALLER_GRAPH YES)
    set(DOXYGEN_CALL_GRAPH YES)
    set(DOXYGEN_EXTRACT_ALL YES)
    set(DOXYGEN_GENERATE_TREEVIEW YES)
    
    # Use SVG for better quality and smaller file sizes
    set(DOXYGEN_DOT_IMAGE_FORMAT svg)
    set(DOXYGEN_DOT_TRANSPARENT YES)

    # Exclude build directories and dependencies
    if(NOT DOXYGEN_EXCLUDE_PATTERNS)
        set(DOXYGEN_EXCLUDE_PATTERNS 
            "${CMAKE_CURRENT_BINARY_DIR}/vcpkg_installed/*"
            "${CMAKE_CURRENT_BINARY_DIR}/_deps/*"
            "${CMAKE_CURRENT_BINARY_DIR}/build/*"
        )
    endif()

    # Optional: Use modern Doxygen theme
    set(DOXYGEN_THEME "awesome-sidebar" CACHE STRING "Doxygen theme (none, awesome, awesome-sidebar)")
    set_property(CACHE DOXYGEN_THEME PROPERTY STRINGS none awesome awesome-sidebar)

    if(DOXYGEN_THEME STREQUAL "awesome" OR DOXYGEN_THEME STREQUAL "awesome-sidebar")
        # Download doxygen-awesome-css theme
        # https://github.com/jothepro/doxygen-awesome-css
        include(FetchContent)
        FetchContent_Declare(
            doxygen_awesome_theme
            URL https://github.com/jothepro/doxygen-awesome-css/archive/refs/tags/v2.3.3.zip
        )
        FetchContent_MakeAvailable(doxygen_awesome_theme)
        
        set(DOXYGEN_HTML_EXTRA_STYLESHEET "${doxygen_awesome_theme_SOURCE_DIR}/doxygen-awesome.css")
        
        if(DOXYGEN_THEME STREQUAL "awesome-sidebar")
            set(DOXYGEN_HTML_EXTRA_STYLESHEET 
                ${DOXYGEN_HTML_EXTRA_STYLESHEET}
                "${doxygen_awesome_theme_SOURCE_DIR}/doxygen-awesome-sidebar-only.css"
            )
        endif()
        
        message(STATUS "Using Doxygen theme: ${DOXYGEN_THEME}")
    else()
        message(STATUS "Using default Doxygen theme")
    endif()

    # Output directory
    set(DOXYGEN_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/out/docs")
    set(DOXYGEN_HTML_OUTPUT ".")

    # Add doxygen target
    doxygen_add_docs(
        docs
        ${PROJECT_SOURCE_DIR}/src
        ${PROJECT_SOURCE_DIR}/include
        COMMENT "Generating API documentation with Doxygen"
    )

    message(STATUS "Doxygen documentation enabled")
    message(STATUS "  Generate docs: cmake --build . --target docs")
    message(STATUS "  Output:        ${PROJECT_SOURCE_DIR}/out/docs/index.html")
endfunction()
