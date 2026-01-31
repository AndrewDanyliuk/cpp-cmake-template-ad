################################################################################
# Code Hardening Configuration
################################################################################
#
# Applies security-focused compiler and linker flags to harden binaries against
# common exploitation techniques including buffer overflows, ROP attacks, and
# speculative execution vulnerabilities.
#
# Usage:
#   include(cmake/Hardening.cmake)
#   # Then call harden() on your targets in src/CMakeLists.txt:
#   harden(${PROJECT_NAME}_lib)
#
# Features:
#   - Position Independent Code (PIE/PIC)
#   - Stack protection
#   - Format string protection
#   - FORTIFY_SOURCE
#   - RELRO (Full)
#   - Control Flow Integrity (where supported)
#   - Speculative execution mitigations (where supported)
#
################################################################################

include(CheckCXXCompilerFlag)

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.18")
    include(CheckLinkerFlag)
endif()

################################################################################
# Helper Functions
################################################################################

# Check and collect supported compiler flags
function(determine_supported_compiler_flags property)
    set(FLAGS_HARDENING "")
    foreach(flag ${ARGN})
        # Create a valid variable name from the flag
        string(REPLACE "=" "_eq_" var_name ${flag})
        string(REPLACE "," "_comma_" var_name ${var_name})
        string(REPLACE "-" "_" var_name ${var_name})
        string(REPLACE "+" "_" var_name ${var_name})
        set(var_name "SUPPORTS_HARDENING_${property}_${var_name}")

        check_cxx_compiler_flag(${flag} ${var_name})
        if(${${var_name}})
            list(APPEND FLAGS_HARDENING "${flag}")
        endif()
    endforeach()

    set(HARDENING_${property} "${FLAGS_HARDENING}" PARENT_SCOPE)
endfunction()

# Check and collect supported linker flags (CMake 3.18+)
function(determine_supported_linker_flags property)
    set(FLAGS_HARDENING "")
    foreach(flag ${ARGN})
        # Create a valid variable name from the flag
        string(REPLACE "=" "_eq_" var_name ${flag})
        string(REPLACE "," "_comma_" var_name ${var_name})
        string(REPLACE "-" "_" var_name ${var_name})
        string(REPLACE "+" "_" var_name ${var_name})
        set(var_name "SUPPORTS_HARDENING_${property}_${var_name}")

        check_linker_flag(CXX ${flag} ${var_name})
        if(${${var_name}})
            list(APPEND FLAGS_HARDENING "${flag}")
        endif()
    endforeach()

    set(HARDENING_${property} "${FLAGS_HARDENING}" PARENT_SCOPE)
endfunction()

# Apply compiler flags to target
function(apply_compiler_flags target property use_cache)
    get_target_property(EXISTING_FLAGS ${target} ${property})
    if(EXISTING_FLAGS MATCHES "NOTFOUND")
        set(EXISTING_FLAGS "")
    endif()

    if(use_cache)
        if(NOT DEFINED CACHE{HARDENING_${property}})
            determine_supported_compiler_flags(${property} ${ARGN})
            set(HARDENING_${property} "${HARDENING_${property}}" CACHE STRING "Cached hardening flags for ${property}")
        endif()
    else()
        determine_supported_compiler_flags(${property} ${ARGN})
    endif()

    set(NEW_FLAGS ${EXISTING_FLAGS})
    list(APPEND NEW_FLAGS ${HARDENING_${property}})
    set_target_properties(${target} PROPERTIES ${property} "${NEW_FLAGS}")
endfunction()

# Apply linker flags to target
function(apply_linker_flags target property use_cache)
    get_target_property(EXISTING_FLAGS ${target} ${property})
    if(EXISTING_FLAGS MATCHES "NOTFOUND")
        set(EXISTING_FLAGS "")
    endif()

    if(use_cache)
        if(NOT DEFINED CACHE{HARDENING_${property}})
            if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.18")
                determine_supported_linker_flags(${property} ${ARGN})
            else()
                determine_supported_compiler_flags(${property} ${ARGN})
            endif()
            set(HARDENING_${property} "${HARDENING_${property}}" CACHE STRING "Cached hardening flags for ${property}")
        endif()
    else()
        if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.18")
            determine_supported_linker_flags(${property} ${ARGN})
        else()
            determine_supported_compiler_flags(${property} ${ARGN})
        endif()
    endif()

    set(NEW_FLAGS ${EXISTING_FLAGS})
    list(APPEND NEW_FLAGS ${HARDENING_${property}})
    set_target_properties(${target} PROPERTIES ${property} "${NEW_FLAGS}")
endfunction()

################################################################################
# Position Independent Code Setup
################################################################################

function(setup_pic target)
    set_property(TARGET ${target} PROPERTY POSITION_INDEPENDENT_CODE ON)

    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        get_target_property(target_type ${target} TYPE)

        set(PIC_COMPILE_FLAGS "")
        set(PIC_LINK_FLAGS "")

        if(target_type STREQUAL "EXECUTABLE")
            list(APPEND PIC_COMPILE_FLAGS "-fPIE")
            # -pie is only needed on Linux; macOS defaults to PIE
            if(CMAKE_SYSTEM_NAME MATCHES "Linux")
                list(APPEND PIC_LINK_FLAGS "-pie")
            endif()
        else()
            list(APPEND PIC_COMPILE_FLAGS "-fPIC")
        endif()

        apply_compiler_flags(${target} COMPILE_OPTIONS OFF ${PIC_COMPILE_FLAGS})
        if(PIC_LINK_FLAGS)
            apply_linker_flags(${target} LINK_OPTIONS OFF ${PIC_LINK_FLAGS})
        endif()

    elseif(MSVC)
        # MSVC handles PIC/PIE differently via /DYNAMICBASE
        target_compile_options(${target} PRIVATE /DYNAMICBASE)
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            target_compile_options(${target} PRIVATE /HIGHENTROPYVA)
        endif()
    endif()
endfunction()

################################################################################
# Main Hardening Function
################################################################################

function(harden target)
    message(STATUS "Applying hardening to target: ${target}")

    # Setup Position Independent Code
    setup_pic(${target})

    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        #-----------------------------------------------------------------------
        # Compiler Warning Flags (Security-focused)
        #-----------------------------------------------------------------------
        set(HARDENING_WARNING_FLAGS
            "-Wall"
            "-Wextra"
            "-Wconversion"
            "-Wformat"
            "-Wformat-security"
            "-Werror=format-security"
        )

        #-----------------------------------------------------------------------
        # Stack Protection
        #-----------------------------------------------------------------------
        set(HARDENING_STACK_FLAGS
            "-fstack-protector-strong"
        )

        # -fstack-clash-protection is not supported on macOS/AppleClang
        if(NOT CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
            list(APPEND HARDENING_STACK_FLAGS "-fstack-clash-protection")
        endif()

        #-----------------------------------------------------------------------
        # Control Flow and Code Generation
        #-----------------------------------------------------------------------
        set(HARDENING_CFI_FLAGS
            "-fno-strict-aliasing"
            "-fno-common"
            "-ftrivial-auto-var-init=zero"
        )

        # ARM-specific branch protection (not supported on AppleClang)
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64" AND NOT CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
            list(APPEND HARDENING_CFI_FLAGS
                "-mbranch-protection=standard"
            )
        endif()

        # x86-specific mitigations (not all supported on AppleClang)
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64|i[3-6]86")
            if(NOT CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
                list(APPEND HARDENING_CFI_FLAGS
                    "-fcf-protection=full"
                    "-mretpoline"
                )

                if(CMAKE_SIZEOF_VOID_P EQUAL 8)
                    list(APPEND HARDENING_CFI_FLAGS
                        "-mspeculative-load-hardening"
                    )
                endif()
            endif()
        endif()

        #-----------------------------------------------------------------------
        # Speculative Execution Mitigations (Optional, may impact performance)
        #-----------------------------------------------------------------------
        if(ENABLE_HARDENING_FULL)
            set(HARDENING_SPECTRE_FLAGS
                "-mharden-sls=all"
                "-fzero-call-used-regs=used-gpr"
            )
        else()
            set(HARDENING_SPECTRE_FLAGS "")
        endif()

        #-----------------------------------------------------------------------
        # Collect All Compiler Flags
        #-----------------------------------------------------------------------
        set(ALL_HARDENING_COMPILE_FLAGS
            ${HARDENING_WARNING_FLAGS}
            ${HARDENING_STACK_FLAGS}
            ${HARDENING_CFI_FLAGS}
            ${HARDENING_SPECTRE_FLAGS}
        )

        #-----------------------------------------------------------------------
        # Linker Flags
        #-----------------------------------------------------------------------
        set(HARDENING_LINK_FLAGS
            "-Wl,-O1"
        )

        # Platform-specific linker flags
        if(CMAKE_SYSTEM_NAME MATCHES "Linux")
            list(APPEND HARDENING_LINK_FLAGS
                "-Wl,-z,relro"          # Partial RELRO
                "-Wl,-z,now"            # Full RELRO (immediate binding)
                "-Wl,-z,noexecstack"    # Non-executable stack
                "-Wl,--as-needed"       # Only link needed libraries
                "-Wl,--sort-common"     # Sort common symbols
            )

            if(ENABLE_HARDENING_FULL)
                list(APPEND HARDENING_LINK_FLAGS
                    "-Wl,-z,ibt"        # Indirect Branch Tracking
                    "-Wl,-z,shstk"      # Shadow Stack
                )
            endif()

        elseif(CMAKE_SYSTEM_NAME MATCHES "Windows" AND NOT MSVC)
            # MinGW
            list(APPEND HARDENING_LINK_FLAGS
                "-Wl,--nxcompat"        # DEP compatible
                "-Wl,--dynamicbase"     # ASLR
                "-Wl,--export-all-symbols"
            )
            if(CMAKE_SIZEOF_VOID_P EQUAL 8)
                list(APPEND HARDENING_LINK_FLAGS
                    "-Wl,--high-entropy-va"  # High-entropy ASLR
                )
            endif()
        endif()

        #-----------------------------------------------------------------------
        # Preprocessor Definitions
        #-----------------------------------------------------------------------
        set(HARDENING_DEFINITIONS
            "-D_FORTIFY_SOURCE=2"
            "-D_GLIBCXX_ASSERTIONS"
        )

        #-----------------------------------------------------------------------
        # Apply All Flags
        #-----------------------------------------------------------------------
        apply_compiler_flags(${target} COMPILE_OPTIONS ON ${ALL_HARDENING_COMPILE_FLAGS})
        apply_linker_flags(${target} LINK_OPTIONS ON ${HARDENING_LINK_FLAGS})
        target_compile_definitions(${target} PRIVATE ${HARDENING_DEFINITIONS})

    elseif(MSVC)
        #-----------------------------------------------------------------------
        # MSVC Hardening
        #-----------------------------------------------------------------------
        target_compile_options(${target} PRIVATE
            /sdl            # Security Development Lifecycle checks
            /GS             # Buffer security check
            /guard:cf       # Control Flow Guard
            /CETCOMPAT      # CET Shadow Stack compatible
        )

        target_link_options(${target} PRIVATE
            /guard:cf       # Control Flow Guard
            /CETCOMPAT      # CET Shadow Stack compatible
            /DYNAMICBASE    # ASLR
            /NXCOMPAT       # DEP
        )

        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            target_link_options(${target} PRIVATE
                /HIGHENTROPYVA  # High-entropy ASLR
            )
        endif()

        target_compile_definitions(${target} PRIVATE
            _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1
            _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT=1
        )

    else()
        message(WARNING "Hardening: Compiler ${CMAKE_CXX_COMPILER_ID} not fully supported")
    endif()

    message(STATUS "Hardening applied to: ${target}")
endfunction()

################################################################################
# Setup Function (called from main CMakeLists.txt)
################################################################################

function(setup_hardening)
    message(STATUS "Hardening: Enabled")
    if(ENABLE_HARDENING_FULL)
        message(STATUS "  Full hardening mode (includes speculative execution mitigations)")
        message(STATUS "  Note: Full mode may impact performance")
    else()
        message(STATUS "  Standard hardening mode")
    endif()
    message(STATUS "  Call harden(<target>) on your targets to apply")
endfunction()
