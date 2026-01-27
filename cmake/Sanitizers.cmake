################################################################################
# Sanitizers Configuration
################################################################################
#
# Sanitizers are runtime checkers that detect bugs like:
#   - AddressSanitizer (ASan): memory errors (use-after-free, buffer overflow)
#   - ThreadSanitizer (TSan): data races
#   - UndefinedBehaviorSanitizer (UBSan): undefined behavior
#   - MemorySanitizer (MSan): uninitialized memory reads
#   - LeakSanitizer (LSan): memory leaks
#
# Note: Some sanitizers conflict (ASan + TSan, ASan + MSan)
#
# Usage:
#   include(cmake/Sanitizers.cmake)
#   configure_sanitizers(
#       ADDRESS ON
#       THREAD OFF
#       UNDEFINED ON
#       MEMORY OFF
#       LEAK OFF
#   )
#
################################################################################

function(configure_sanitizers)
    # Parse arguments
    set(options "")
    set(oneValueArgs ADDRESS THREAD UNDEFINED MEMORY LEAK)
    set(multiValueArgs "")
    cmake_parse_arguments(SAN "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # Check for conflicts
    if(SAN_ADDRESS AND SAN_THREAD)
        message(FATAL_ERROR "AddressSanitizer and ThreadSanitizer cannot be enabled together")
    endif()
    
    if(SAN_ADDRESS AND SAN_MEMORY)
        message(FATAL_ERROR "AddressSanitizer and MemorySanitizer cannot be enabled together")
    endif()
    
    if(SAN_THREAD AND SAN_MEMORY)
        message(FATAL_ERROR "ThreadSanitizer and MemorySanitizer cannot be enabled together")
    endif()
    
    # Only GCC and Clang support sanitizers
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        if(SAN_ADDRESS OR SAN_THREAD OR SAN_UNDEFINED OR SAN_MEMORY OR SAN_LEAK)
            message(WARNING "Sanitizers require GCC or Clang compiler")
        endif()
        return()
    endif()
    
    # Collect enabled sanitizers
    set(SANITIZER_FLAGS "")
    
    if(SAN_ADDRESS)
        list(APPEND SANITIZER_FLAGS "address")
        message(STATUS "Sanitizer: AddressSanitizer (ASan) enabled")
    endif()
    
    if(SAN_THREAD)
        list(APPEND SANITIZER_FLAGS "thread")
        message(STATUS "Sanitizer: ThreadSanitizer (TSan) enabled")
    endif()
    
    if(SAN_UNDEFINED)
        list(APPEND SANITIZER_FLAGS "undefined")
        message(STATUS "Sanitizer: UndefinedBehaviorSanitizer (UBSan) enabled")
    endif()
    
    if(SAN_MEMORY)
        if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            message(WARNING "MemorySanitizer requires Clang compiler")
        else()
            list(APPEND SANITIZER_FLAGS "memory")
            message(STATUS "Sanitizer: MemorySanitizer (MSan) enabled")
        endif()
    endif()
    
    if(SAN_LEAK)
        # LeakSanitizer is part of AddressSanitizer on most platforms
        if(NOT SAN_ADDRESS)
            list(APPEND SANITIZER_FLAGS "leak")
            message(STATUS "Sanitizer: LeakSanitizer (LSan) enabled")
        else()
            message(STATUS "Sanitizer: LeakSanitizer included with AddressSanitizer")
        endif()
    endif()
    
    # Apply sanitizer flags
    if(SANITIZER_FLAGS)
        list(JOIN SANITIZER_FLAGS "," SANITIZER_STRING)
        
        add_compile_options(-fsanitize=${SANITIZER_STRING})
        add_link_options(-fsanitize=${SANITIZER_STRING})
        
        # Additional recommended flags for better error messages
        add_compile_options(-fno-omit-frame-pointer)
        add_compile_options(-g)
        
        message(STATUS "Sanitizer flags: -fsanitize=${SANITIZER_STRING}")
        message(STATUS "")
        message(STATUS "Sanitizer Usage:")
        message(STATUS "  Build and run tests normally")
        message(STATUS "  Sanitizers will report errors at runtime")
        message(STATUS "")
        
        # Environment variable hints
        if(SAN_ADDRESS)
            message(STATUS "AddressSanitizer options (set before running):")
            message(STATUS "  export ASAN_OPTIONS=detect_leaks=1:check_initialization_order=1")
        endif()
        
        if(SAN_UNDEFINED)
            message(STATUS "UndefinedBehaviorSanitizer options (set before running):")
            message(STATUS "  export UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1")
        endif()
        
        if(SAN_THREAD)
            message(STATUS "ThreadSanitizer options (set before running):")
            message(STATUS "  export TSAN_OPTIONS=second_deadlock_stack=1")
        endif()
        
        message(STATUS "")
    else()
        message(STATUS "No sanitizers enabled")
    endif()
endfunction()
