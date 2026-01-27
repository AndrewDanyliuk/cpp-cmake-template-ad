################################################################################
# Cppcheck Configuration
################################################################################
#
# Cppcheck is a static analysis tool for C/C++ code that detects bugs,
# undefined behavior, and dangerous coding constructs.
#
# Usage:
#   include(cmake/Cppcheck.cmake)
#   setup_cppcheck()
#
################################################################################

function(setup_cppcheck)
    find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)
    
    if(NOT CPPCHECK_EXECUTABLE)
        message(WARNING "cppcheck requested but not found")
        message(STATUS "Install instructions:")
        message(STATUS "  Ubuntu/Debian: sudo apt-get install cppcheck")
        message(STATUS "  macOS:         brew install cppcheck")
        message(STATUS "  Windows:       choco install cppcheck")
        return()
    endif()

    message(STATUS "Found cppcheck: ${CPPCHECK_EXECUTABLE}")
    
    # Determine template based on generator
    if(CMAKE_GENERATOR MATCHES "Visual Studio")
        set(CPPCHECK_TEMPLATE "vs")
    else()
        set(CPPCHECK_TEMPLATE "gcc")
    endif()
    
    # Configure cppcheck
    set(CMAKE_CXX_CPPCHECK
        "${CPPCHECK_EXECUTABLE}"
        "--template=${CPPCHECK_TEMPLATE}"
        "--enable=warning,performance,portability,style"
        "--inline-suppr"
        "--suppress=missingIncludeSystem"
        "--suppress=unmatchedSuppression"
        "--suppress=unusedFunction"
        # Add C++ standard
        "--std=c++${CMAKE_CXX_STANDARD}"
        # Suppress warnings from dependencies
        "--suppress=*:${CMAKE_BINARY_DIR}/_deps/*"
    )
    
    # Export to parent scope
    set(CMAKE_CXX_CPPCHECK "${CMAKE_CXX_CPPCHECK}" PARENT_SCOPE)
    
    message(STATUS "Cppcheck enabled")
    message(STATUS "  Template:  ${CPPCHECK_TEMPLATE}")
    message(STATUS "  Standard:  C++${CMAKE_CXX_STANDARD}")
    
    # Create manual check target
    file(GLOB_RECURSE ALL_SOURCE_FILES
        "${CMAKE_SOURCE_DIR}/src/*.cpp"
        "${CMAKE_SOURCE_DIR}/src/*.hpp"
        "${CMAKE_SOURCE_DIR}/include/*.hpp"
        "${CMAKE_SOURCE_DIR}/include/*.h"
    )
    
    if(ALL_SOURCE_FILES)
        add_custom_target(cppcheck-check
            COMMAND ${CPPCHECK_EXECUTABLE}
                --template=${CPPCHECK_TEMPLATE}
                --enable=all
                --std=c++${CMAKE_CXX_STANDARD}
                --project=${CMAKE_BINARY_DIR}/compile_commands.json
                --suppress=missingIncludeSystem
                --suppress=unmatchedSuppression
                --inline-suppr
                --error-exitcode=1
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            COMMENT "Running cppcheck with full analysis"
        )
        message(STATUS "  Manual check: cmake --build . --target cppcheck-check")
    endif()
endfunction()
