################################################################################
# Clang-Format Configuration
################################################################################
#
# Clang-Format is a tool to automatically format C++ code according to
# a specified style guide (.clang-format file).
#
# Usage:
#   include(cmake/ClangFormat.cmake)
#   setup_clang_format()
#
################################################################################

function(setup_clang_format)
    find_program(CLANG_FORMAT_EXECUTABLE NAMES clang-format)
    
    if(NOT CLANG_FORMAT_EXECUTABLE)
        message(WARNING "clang-format requested but not found")
        message(STATUS "Install instructions:")
        message(STATUS "  Ubuntu/Debian: sudo apt-get install clang-format")
        message(STATUS "  macOS:         brew install clang-format")
        message(STATUS "  Windows:       choco install llvm")
        return()
    endif()

    message(STATUS "Found clang-format: ${CLANG_FORMAT_EXECUTABLE}")
    
    # Find all source files
    file(GLOB_RECURSE ALL_SOURCE_FILES
        "${CMAKE_SOURCE_DIR}/src/*.cpp"
        "${CMAKE_SOURCE_DIR}/src/*.hpp"
        "${CMAKE_SOURCE_DIR}/include/*.hpp"
        "${CMAKE_SOURCE_DIR}/include/*.h"
        "${CMAKE_SOURCE_DIR}/tests/*.cpp"
        "${CMAKE_SOURCE_DIR}/tests/*.hpp"
    )
    
    if(NOT ALL_SOURCE_FILES)
        message(WARNING "No source files found for clang-format")
        return()
    endif()
    
    # Create format target (applies formatting)
    add_custom_target(format
        COMMAND ${CLANG_FORMAT_EXECUTABLE}
            -i
            -style=file
            ${ALL_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Formatting source code with clang-format"
        VERBATIM
    )
    
    # Create format-check target (checks formatting without modifying)
    add_custom_target(format-check
        COMMAND ${CLANG_FORMAT_EXECUTABLE}
            --dry-run
            --Werror
            -style=file
            ${ALL_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Checking code formatting"
        VERBATIM
    )
    
    message(STATUS "Clang-format targets created")
    message(STATUS "  Configuration: .clang-format file in project root")
    message(STATUS "  Format code:   cmake --build . --target format")
    message(STATUS "  Check format:  cmake --build . --target format-check")
endfunction()
