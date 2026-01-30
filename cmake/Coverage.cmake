################################################################################
# Coverage Configuration
################################################################################
#
# Supports two coverage tools:
#   1. llvm-cov (recommended for Clang) - provides better integration with LLVM
#   2. gcov/lcov (fallback for GCC or when llvm-cov unavailable)
#
# Usage:
#   include(cmake/Coverage.cmake)
#   setup_coverage(llvm-cov)  # or setup_coverage(gcov)
#
################################################################################

function(setup_coverage TOOL)
    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug" AND NOT CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
        message(WARNING "Coverage is most accurate with Debug or RelWithDebInfo build types")
    endif()

    if(TOOL STREQUAL "llvm-cov")
        setup_llvm_coverage()
    elseif(TOOL STREQUAL "gcov")
        setup_gcov_coverage()
    else()
        message(FATAL_ERROR "Unknown coverage tool: ${TOOL}. Use 'llvm-cov' or 'gcov'")
    endif()
endfunction()

################################################################################
# LLVM Coverage (Clang)
################################################################################

function(setup_llvm_coverage)
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        message(WARNING "llvm-cov requested but compiler is not Clang. Falling back to gcov.")
        setup_gcov_coverage()
        return()
    endif()

    # Check if llvm-cov and llvm-profdata are available
    find_program(LLVM_COV_EXECUTABLE NAMES llvm-cov)
    find_program(LLVM_PROFDATA_EXECUTABLE NAMES llvm-profdata)

    if(NOT LLVM_COV_EXECUTABLE OR NOT LLVM_PROFDATA_EXECUTABLE)
        message(WARNING "llvm-cov or llvm-profdata not found. Falling back to gcov.")
        setup_gcov_coverage()
        return()
    endif()

    message(STATUS "Coverage: Using llvm-cov")
    message(STATUS "  llvm-cov:      ${LLVM_COV_EXECUTABLE}")
    message(STATUS "  llvm-profdata: ${LLVM_PROFDATA_EXECUTABLE}")

    # Compiler flags for source-based code coverage
    # See: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
    set(COVERAGE_COMPILE_FLAGS
        -fprofile-instr-generate
        -fcoverage-mapping
    )
    
    set(COVERAGE_LINK_FLAGS
        -fprofile-instr-generate
        -fcoverage-mapping
    )

    # Apply flags globally
    add_compile_options(${COVERAGE_COMPILE_FLAGS})
    add_link_options(${COVERAGE_LINK_FLAGS})

    # Coverage output directory
    set(COVERAGE_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/out/coverage")

    # Create coverage targets
    add_custom_target(coverage-clean
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${COVERAGE_OUTPUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${COVERAGE_OUTPUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E touch ${COVERAGE_OUTPUT_DIR}/.keep
        COMMENT "Cleaning coverage data"
    )

    # Get test executable name
    set(TEST_EXECUTABLE "${CMAKE_BINARY_DIR}/tests/${PROJECT_NAME}_tests")

    # Add coverage-report target for llvm-cov
    add_custom_target(coverage-report
        COMMAND ${LLVM_PROFDATA_EXECUTABLE} merge -sparse
            ${CMAKE_BINARY_DIR}/default.profraw
            -o ${CMAKE_BINARY_DIR}/default.profdata
        COMMAND ${LLVM_COV_EXECUTABLE} show ${TEST_EXECUTABLE}
            -instr-profile=${CMAKE_BINARY_DIR}/default.profdata
            -format=html
            -output-dir=${COVERAGE_OUTPUT_DIR}
            -show-line-counts-or-regions
            -ignore-filename-regex='.*/tests/.*'
            -ignore-filename-regex='.*/build/.*'
            -Xdemangler=c++filt -Xdemangler=-n
        COMMENT "Generating HTML coverage report in ${COVERAGE_OUTPUT_DIR}"
    )

    # Instructions for generating coverage
    message(STATUS "")
    message(STATUS "To generate coverage report:")
    message(STATUS "  1. Build with coverage enabled")
    message(STATUS "  2. Run tests: ctest (or run test executable directly)")
    message(STATUS "  3. Generate report: cmake --build . --target coverage-report")
    message(STATUS "  4. View report: open ${COVERAGE_OUTPUT_DIR}/index.html")
    message(STATUS "")

    # Common llvm-cov options:
    # -show-line-counts-or-regions: Show execution counts or region markers
    # -show-instantiations: Show function instantiations
    # -show-expansions: Show macro expansions
    # -ignore-filename-regex=<pattern>: Skip files matching pattern (e.g., '.*/tests/.*')
endfunction()

################################################################################
# GCC Coverage (gcov/lcov)
################################################################################

function(setup_gcov_coverage)
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(FATAL_ERROR "Coverage with gcov requires GCC or Clang compiler")
    endif()

    # Check if gcov is available
    find_program(GCOV_EXECUTABLE NAMES gcov)
    if(NOT GCOV_EXECUTABLE)
        message(FATAL_ERROR "gcov not found. Install gcc or run with -DENABLE_COVERAGE=OFF")
    endif()

    # Check if lcov is available (optional, for HTML reports)
    find_program(LCOV_EXECUTABLE NAMES lcov)
    find_program(GENHTML_EXECUTABLE NAMES genhtml)

    message(STATUS "Coverage: Using gcov")
    message(STATUS "  gcov:    ${GCOV_EXECUTABLE}")
    if(LCOV_EXECUTABLE)
        message(STATUS "  lcov:    ${LCOV_EXECUTABLE}")
        message(STATUS "  genhtml: ${GENHTML_EXECUTABLE}")
    else()
        message(STATUS "  lcov:    NOT FOUND (install lcov for HTML reports)")
    endif()

    # Compiler flags for gcov
    set(COVERAGE_COMPILE_FLAGS
        --coverage      # Equivalent to -fprofile-arcs -ftest-coverage
        -O0             # Disable optimizations for accurate coverage
        -g              # Include debug info
    )
    
    set(COVERAGE_LINK_FLAGS
        --coverage
    )

    # Apply flags globally
    add_compile_options(${COVERAGE_COMPILE_FLAGS})
    add_link_options(${COVERAGE_LINK_FLAGS})

    # Coverage output directory
    set(COVERAGE_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/out/coverage")

    # Create coverage targets
    add_custom_target(coverage-clean
        COMMAND find ${CMAKE_BINARY_DIR} -type f -name '*.gcda' -delete
        COMMAND find ${CMAKE_BINARY_DIR} -type f -name '*.gcno' -delete
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${COVERAGE_OUTPUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${COVERAGE_OUTPUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E touch ${COVERAGE_OUTPUT_DIR}/.keep
        COMMENT "Cleaning coverage data (.gcda, .gcno files)"
    )

    if(LCOV_EXECUTABLE AND GENHTML_EXECUTABLE)
        add_custom_target(coverage-report
            COMMAND ${LCOV_EXECUTABLE}
                --capture
                --directory ${CMAKE_BINARY_DIR}
                --output-file ${CMAKE_BINARY_DIR}/coverage.info
                --gcov-tool ${GCOV_EXECUTABLE}
            COMMAND ${LCOV_EXECUTABLE}
                --remove ${CMAKE_BINARY_DIR}/coverage.info
                '/usr/*' '*/tests/*' '*/build/*' '*/.*'
                --output-file ${CMAKE_BINARY_DIR}/coverage.info
            COMMAND ${GENHTML_EXECUTABLE}
                ${CMAKE_BINARY_DIR}/coverage.info
                --output-directory ${COVERAGE_OUTPUT_DIR}
                --demangle-cpp
            COMMENT "Generating HTML coverage report in ${COVERAGE_OUTPUT_DIR}"
        )

        message(STATUS "")
        message(STATUS "To generate coverage report:")
        message(STATUS "  1. Build with coverage enabled")
        message(STATUS "  2. Run tests: ctest")
        message(STATUS "  3. Generate report: cmake --build . --target coverage-report")
        message(STATUS "  4. View report: open ${COVERAGE_OUTPUT_DIR}/index.html")
        message(STATUS "")
    else()
        message(STATUS "")
        message(STATUS "To generate coverage report:")
        message(STATUS "  1. Build with coverage enabled")
        message(STATUS "  2. Run tests: ctest")
        message(STATUS "  3. Generate coverage: gcov <source_files>")
        message(STATUS "  Note: Install lcov for automated HTML reports")
        message(STATUS "")
    endif()
endfunction()
