################################################################################
# Interprocedural Optimization (IPO) / Link-Time Optimization (LTO)
################################################################################
#
# Enables whole-program optimization by deferring optimization decisions to
# link time, allowing the compiler to optimize across translation unit boundaries.
#
# Usage:
#   include(cmake/IPO.cmake)
#   setup_ipo()
#
# Benefits:
#   - Cross-module inlining
#   - Dead code elimination across modules
#   - Better register allocation
#   - Typically 5-20% performance improvement
#
# Considerations:
#   - Increases link time significantly
#   - Increases memory usage during linking
#   - May increase build times
#   - Best used for Release builds
#
################################################################################

include(CheckIPOSupported)

################################################################################
# Global IPO Setup
################################################################################

function(setup_ipo)
    # Check if IPO/LTO is supported
    # Note: ccache may interfere with IPO detection, so we also check compiler ID
    check_ipo_supported(RESULT IPO_SUPPORTED OUTPUT IPO_OUTPUT)

    # AppleClang and Clang support LTO even if the check fails (often due to ccache)
    if(NOT IPO_SUPPORTED AND CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
        message(STATUS "IPO/LTO: Check failed but compiler supports LTO, enabling anyway")
        set(IPO_SUPPORTED TRUE)
    endif()

    if(IPO_SUPPORTED)
        message(STATUS "IPO/LTO: Supported and enabled")

        # Set global property for all targets
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON PARENT_SCOPE)

        # For thin LTO (faster linking, slightly less optimization)
        if(ENABLE_IPO_THIN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                message(STATUS "  Using ThinLTO (faster link times)")
                add_compile_options(-flto=thin)
                add_link_options(-flto=thin)
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "8.0")
                message(STATUS "  Using GCC LTO with jobserver")
                # GCC doesn't have ThinLTO, but we can use parallel LTO
                add_compile_options(-flto=auto)
                add_link_options(-flto=auto)
            else()
                message(STATUS "  Using standard LTO")
            endif()
        else()
            message(STATUS "  Using full LTO (maximum optimization)")

            if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
                add_compile_options(-flto=full)
                add_link_options(-flto=full)
            elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
                add_compile_options(-flto)
                add_link_options(-flto)
            endif()
        endif()

        # Additional optimization flags that work well with LTO
        if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
            # Fat LTO objects allow non-LTO linking as fallback
            if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
                add_compile_options(-ffat-lto-objects)
            endif()
        endif()

        # MSVC LTO
        if(MSVC)
            message(STATUS "  Using MSVC Whole Program Optimization")
            add_compile_options(/GL)      # Whole program optimization
            add_link_options(/LTCG)       # Link-time code generation
        endif()

    else()
        message(WARNING "IPO/LTO: Not supported by this compiler/platform")
        message(STATUS "  Reason: ${IPO_OUTPUT}")
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF PARENT_SCOPE)
    endif()
endfunction()

################################################################################
# Per-Target IPO Setup
################################################################################

# Enable IPO for a specific target (useful when global IPO is disabled)
function(enable_ipo_for_target target)
    check_ipo_supported(RESULT IPO_SUPPORTED OUTPUT IPO_OUTPUT)

    if(IPO_SUPPORTED)
        set_target_properties(${target} PROPERTIES
            INTERPROCEDURAL_OPTIMIZATION TRUE
        )
        message(STATUS "IPO/LTO enabled for target: ${target}")
    else()
        message(WARNING "IPO/LTO not available for target ${target}: ${IPO_OUTPUT}")
    endif()
endfunction()

# Disable IPO for a specific target (useful when global IPO is enabled but
# you need to exclude certain targets, e.g., for debugging)
function(disable_ipo_for_target target)
    set_target_properties(${target} PROPERTIES
        INTERPROCEDURAL_OPTIMIZATION FALSE
    )
    message(STATUS "IPO/LTO disabled for target: ${target}")
endfunction()

################################################################################
# LTO Cache Setup (for faster incremental builds)
################################################################################

function(setup_lto_cache)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # Clang ThinLTO cache directory
        set(LTO_CACHE_DIR "${CMAKE_BINARY_DIR}/lto-cache")
        file(MAKE_DIRECTORY ${LTO_CACHE_DIR})

        add_link_options(-Wl,--thinlto-cache-dir=${LTO_CACHE_DIR})
        message(STATUS "ThinLTO cache directory: ${LTO_CACHE_DIR}")

    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10.0")
        # GCC LTO cache (requires GCC 10+)
        set(LTO_CACHE_DIR "${CMAKE_BINARY_DIR}/lto-cache")
        file(MAKE_DIRECTORY ${LTO_CACHE_DIR})

        # GCC uses different mechanism - jobserver for parallel LTO
        message(STATUS "GCC LTO with parallel processing enabled")
    endif()
endfunction()
