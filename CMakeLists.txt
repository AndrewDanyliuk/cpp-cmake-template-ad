cmake_minimum_required(VERSION 3.23)

# Prevent in-source builds
include(cmake/PreventInSourceBuilds.cmake)

################################################################################
# Read cmake.options for defaults (presets take precedence)
################################################################################
if(EXISTS "${CMAKE_SOURCE_DIR}/cmake.options")
    file(STRINGS "${CMAKE_SOURCE_DIR}/cmake.options" CONFIG_LINES)
    foreach(LINE ${CONFIG_LINES})
        # Skip comments and empty lines
        string(REGEX MATCH "^[ ]*#" COMMENT ${LINE})
        string(STRIP "${LINE}" LINE_STRIPPED)
        if(NOT COMMENT AND NOT LINE_STRIPPED STREQUAL "")
            # Parse KEY=VALUE
            string(REGEX MATCH "^([A-Za-z_][A-Za-z0-9_]*)=(.*)$" MATCHED ${LINE})
            if(MATCHED)
                set(KEY ${CMAKE_MATCH_1})
                set(VALUE ${CMAKE_MATCH_2})
                string(STRIP "${VALUE}" VALUE)
                
                # Only set if not already defined (presets/command line take precedence)
                if(NOT DEFINED ${KEY})
                    set(${KEY} ${VALUE})
                    message(STATUS "Default from cmake.options: ${KEY} = ${VALUE}")
                else()
                    message(STATUS "Overriding cmake.options ${KEY}: ${${KEY}} (from preset/command line)")
                endif()
            endif()
        endif()
    endforeach()
endif()

################################################################################
# Project Definition
################################################################################

# Set C++ standard from options (can be overridden by presets)
if(NOT DEFINED CMAKE_CXX_STANDARD)
    if(DEFINED CXX_STANDARD)
        set(CMAKE_CXX_STANDARD ${CXX_STANDARD})
    else()
        set(CMAKE_CXX_STANDARD 17)  # Fallback default
    endif()
endif()

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(PROJECT_NAME_CAMEL
    VERSION 1.0.0
    DESCRIPTION "PROJECT_NAME_CAMEL C++ Project"
    LANGUAGES CXX
)

# Export compile commands for clang-tidy and other tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

################################################################################
# CMake Options (can be overridden by presets or command line)
################################################################################

option(ENABLE_TESTING "Enable unit testing with Catch2" ON)
option(ENABLE_COVERAGE "Enable code coverage reporting" OFF)
option(ENABLE_CPPCHECK "Enable cppcheck static analysis" OFF)
option(ENABLE_CLANG_TIDY "Enable clang-tidy static analysis" OFF)
option(ENABLE_CLANG_FORMAT "Enable clang-format targets" OFF)
option(ENABLE_DOXYGEN "Enable Doxygen documentation generation" OFF)
option(ENABLE_CCACHE "Enable ccache for faster recompilation" OFF)

# Sanitizer options
option(ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
option(ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
option(ENABLE_SANITIZER_UNDEFINED "Enable undefined behavior sanitizer" OFF)
option(ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
option(ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)

# Security hardening options
option(ENABLE_HARDENING "Enable security hardening compiler/linker flags" OFF)
option(ENABLE_HARDENING_FULL "Enable full hardening including speculative execution mitigations (may impact performance)" OFF)

# Link-Time Optimization options
option(ENABLE_IPO "Enable Interprocedural Optimization / Link-Time Optimization" OFF)
option(ENABLE_IPO_THIN "Use ThinLTO instead of full LTO (faster linking)" OFF)

# Coverage tool selection
set(COVERAGE_TOOL "llvm-cov" CACHE STRING "Coverage tool to use (llvm-cov or gcov)")
set_property(CACHE COVERAGE_TOOL PROPERTY STRINGS llvm-cov gcov)

# Package manager selection
set(PACKAGE_MANAGER "CPM" CACHE STRING "Package manager to use (CPM, VCPKG, or NONE)")
set_property(CACHE PACKAGE_MANAGER PROPERTY STRINGS CPM VCPKG NONE)

################################################################################
# Package Manager Setup
################################################################################

if(PACKAGE_MANAGER STREQUAL "VCPKG")
    if(DEFINED ENV{VCPKG_ROOT})
        set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
            CACHE STRING "Vcpkg toolchain file")
        message(STATUS "Using vcpkg from: $ENV{VCPKG_ROOT}")
    else()
        message(FATAL_ERROR "VCPKG selected but VCPKG_ROOT environment variable not set")
    endif()
elseif(PACKAGE_MANAGER STREQUAL "CPM")
    include(cmake/CPM.cmake)
    set(CPM_USE_LOCAL_PACKAGES ON)
    message(STATUS "Using CPM for package management")
elseif(PACKAGE_MANAGER STREQUAL "NONE")
    message(STATUS "Manual dependency management - no package manager")
else()
    message(FATAL_ERROR "Unknown PACKAGE_MANAGER: ${PACKAGE_MANAGER}")
endif()

################################################################################
# Compiler Cache (ccache)
################################################################################

if(ENABLE_CCACHE)
    include(cmake/Ccache.cmake)
endif()

################################################################################
# Coverage Configuration
################################################################################

if(ENABLE_COVERAGE)
    include(cmake/Coverage.cmake)
    setup_coverage(${COVERAGE_TOOL})
endif()

################################################################################
# Dependencies (added BEFORE static analysis so they are excluded)
################################################################################

if(ENABLE_TESTING)
    if(PACKAGE_MANAGER STREQUAL "CPM")
        # Use Catch2 v2 for C++11, v3 for C++14+
        if(CMAKE_CXX_STANDARD EQUAL 11)
            message(STATUS "Using Catch2 v2 for C++11 compatibility")
            CPMAddPackage(
                NAME Catch2
                GITHUB_REPOSITORY catchorg/Catch2
                VERSION 2.13.10
                SYSTEM YES
            )
        else()
            message(STATUS "Using Catch2 v3 for C++14+")
            CPMAddPackage(
                NAME Catch2
                GITHUB_REPOSITORY catchorg/Catch2
                VERSION 3.5.2
                SYSTEM YES
            )
        endif()

        # Google Mock (for mocking)
        CPMAddPackage(
            NAME googletest
            GITHUB_REPOSITORY google/googletest
            VERSION 1.14.0
            SYSTEM YES
            OPTIONS
                "INSTALL_GTEST OFF"
                "gtest_force_shared_crt ON"
        )
    elseif(PACKAGE_MANAGER STREQUAL "VCPKG")
        find_package(Catch2 3 QUIET)
        if(NOT Catch2_FOUND)
            find_package(Catch2 2 REQUIRED)
        endif()
        find_package(GTest REQUIRED)
    endif()
endif()

################################################################################
# Static Analysis Tools (added AFTER dependencies to exclude them)
################################################################################

if(ENABLE_CLANG_TIDY)
    include(cmake/ClangTidy.cmake)
    setup_clang_tidy()
endif()

if(ENABLE_CPPCHECK)
    include(cmake/Cppcheck.cmake)
    setup_cppcheck()
endif()

if(ENABLE_CLANG_FORMAT)
    include(cmake/ClangFormat.cmake)
    setup_clang_format()
endif()

################################################################################
# Pre-commit Hooks
################################################################################

include(cmake/PreCommit.cmake)
setup_pre_commit()
# Sanitizers
################################################################################

include(cmake/Sanitizers.cmake)
configure_sanitizers(
    ADDRESS ${ENABLE_SANITIZER_ADDRESS}
    THREAD ${ENABLE_SANITIZER_THREAD}
    UNDEFINED ${ENABLE_SANITIZER_UNDEFINED}
    MEMORY ${ENABLE_SANITIZER_MEMORY}
    LEAK ${ENABLE_SANITIZER_LEAK}
)

################################################################################
# Security Hardening
################################################################################

if(ENABLE_HARDENING)
    include(cmake/Hardening.cmake)
    setup_hardening()
endif()

################################################################################
# Interprocedural Optimization (LTO)
################################################################################

if(ENABLE_IPO)
    include(cmake/IPO.cmake)
    setup_ipo()
endif()

################################################################################
# Documentation
################################################################################

if(ENABLE_DOXYGEN)
    include(cmake/Doxygen.cmake)
    setup_doxygen()
endif()

################################################################################
# Project Targets
################################################################################

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)

# Add subdirectories
add_subdirectory(src)

if(ENABLE_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

################################################################################
# Summary
################################################################################

message(STATUS "")
message(STATUS "========================================")
message(STATUS "  ${PROJECT_NAME} Configuration Summary")
message(STATUS "========================================")
message(STATUS "C++ Standard:         ${CMAKE_CXX_STANDARD}")
message(STATUS "Build Type:           ${CMAKE_BUILD_TYPE}")
message(STATUS "Package Manager:      ${PACKAGE_MANAGER}")
message(STATUS "Compiler:             ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "")
message(STATUS "Features:")
message(STATUS "  Testing:            ${ENABLE_TESTING}")
message(STATUS "  Coverage:           ${ENABLE_COVERAGE}")
if(ENABLE_COVERAGE)
message(STATUS "  Coverage Tool:      ${COVERAGE_TOOL}")
endif()
message(STATUS "  Clang-Tidy:         ${ENABLE_CLANG_TIDY}")
message(STATUS "  Cppcheck:           ${ENABLE_CPPCHECK}")
message(STATUS "  Clang-Format:       ${ENABLE_CLANG_FORMAT}")
message(STATUS "  Doxygen:            ${ENABLE_DOXYGEN}")
message(STATUS "  Ccache:             ${ENABLE_CCACHE}")
message(STATUS "  Pre-commit:         ${ENABLE_PRE_COMMIT}")
message(STATUS "")
message(STATUS "Sanitizers:")
message(STATUS "  Address:            ${ENABLE_SANITIZER_ADDRESS}")
message(STATUS "  Thread:             ${ENABLE_SANITIZER_THREAD}")
message(STATUS "  Undefined:          ${ENABLE_SANITIZER_UNDEFINED}")
message(STATUS "  Memory:             ${ENABLE_SANITIZER_MEMORY}")
message(STATUS "  Leak:               ${ENABLE_SANITIZER_LEAK}")
message(STATUS "")
message(STATUS "Security & Optimization:")
message(STATUS "  Hardening:          ${ENABLE_HARDENING}")
if(ENABLE_HARDENING)
message(STATUS "  Hardening Full:     ${ENABLE_HARDENING_FULL}")
endif()
message(STATUS "  IPO/LTO:            ${ENABLE_IPO}")
if(ENABLE_IPO)
message(STATUS "  ThinLTO:            ${ENABLE_IPO_THIN}")
endif()
message(STATUS "========================================")
message(STATUS "")
