################################################################################
# Ccache Configuration
################################################################################
#
# Ccache (Compiler Cache) speeds up recompilation by caching previous
# compilations and detecting when the same compilation is being done again.
#
# Usage:
#   option(ENABLE_CCACHE "Enable ccache" ON)
#   if(ENABLE_CCACHE)
#       include(cmake/Ccache.cmake)
#   endif()
#
################################################################################

# Try to find ccache
find_program(CCACHE_EXECUTABLE ccache)

if(CCACHE_EXECUTABLE)
    message(STATUS "Found ccache: ${CCACHE_EXECUTABLE}")
    
    # Set ccache as the compiler launcher
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_EXECUTABLE}")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_EXECUTABLE}")
    
    # Optional: Configure ccache behavior via environment variables
    # These can also be set in ~/.ccache/ccache.conf
    
    # Set maximum cache size (default is 5GB)
    # set(ENV{CCACHE_MAXSIZE} "10G")
    
    # Set cache directory (default is ~/.ccache)
    # set(ENV{CCACHE_DIR} "${CMAKE_BINARY_DIR}/.ccache")
    
    # Enable compression to save disk space
    # set(ENV{CCACHE_COMPRESS} "true")
    
    # Show statistics
    if(CMAKE_GENERATOR MATCHES "Ninja")
        # Ninja already shows what's being compiled
        set(ENV{CCACHE_QUIET} "true")
    endif()
    
    message(STATUS "Ccache enabled - compilation will be accelerated")
    message(STATUS "  View statistics: ccache -s")
    message(STATUS "  Clear cache:     ccache -C")
    message(STATUS "  Show config:     ccache -p")
    
else()
    message(WARNING "Ccache requested but not found. Install ccache for faster rebuilds.")
    message(STATUS "Install instructions:")
    message(STATUS "  Ubuntu/Debian: sudo apt-get install ccache")
    message(STATUS "  macOS:         brew install ccache")
    message(STATUS "  Windows:       choco install ccache")
endif()
