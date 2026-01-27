################################################################################
# Clang-Tidy Configuration
################################################################################
#
# Clang-Tidy is a clang-based C++ linter tool that provides static analysis.
# It can catch bugs, suggest modern C++ idioms, and enforce coding standards.
#
# Usage:
#   include(cmake/ClangTidy.cmake)
#   setup_clang_tidy()
#
################################################################################

function(setup_clang_tidy)
    find_program(CLANG_TIDY_EXECUTABLE NAMES clang-tidy)
    
    if(NOT CLANG_TIDY_EXECUTABLE)
        message(WARNING "clang-tidy requested but not found")
        message(STATUS "Install instructions:")
        message(STATUS "  Ubuntu/Debian: sudo apt-get install clang-tidy")
        message(STATUS "  macOS:         brew install llvm")
        message(STATUS "  Windows:       Install LLVM from https://releases.llvm.org/")
        return()
    endif()

    message(STATUS "Found clang-tidy: ${CLANG_TIDY_EXECUTABLE}")
    
    # Set clang-tidy as the linter
    set(CMAKE_CXX_CLANG_TIDY 
        "${CLANG_TIDY_EXECUTABLE}"
        # Add any default arguments here
        # "-checks=-*,modernize-*,readability-*"
    )
    
    # Export to parent scope so it affects all targets
    set(CMAKE_CXX_CLANG_TIDY "${CMAKE_CXX_CLANG_TIDY}" PARENT_SCOPE)
    
    message(STATUS "Clang-tidy enabled")
    message(STATUS "  Configuration: .clang-tidy file in project root")
    message(STATUS "  To customize: Edit .clang-tidy file")
    
    # Create a target to run clang-tidy manually
    if(NOT TARGET clang-tidy-check)
        find_package(Python3 COMPONENTS Interpreter)
        if(Python3_FOUND)
            # Use run-clang-tidy for parallel execution if available
            find_program(RUN_CLANG_TIDY_EXECUTABLE NAMES run-clang-tidy run-clang-tidy.py)
            if(RUN_CLANG_TIDY_EXECUTABLE)
                add_custom_target(clang-tidy-check
                    COMMAND ${RUN_CLANG_TIDY_EXECUTABLE}
                        -p ${CMAKE_BINARY_DIR}
                        -header-filter='${CMAKE_SOURCE_DIR}/*'
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                    COMMENT "Running clang-tidy on all files"
                )
                message(STATUS "  Manual check:    cmake --build . --target clang-tidy-check")
            endif()
        endif()
    endif()
endfunction()
