#
# This function will prevent in-source builds
#
function(prevent_in_source_builds)
    # Make sure the user doesn't play dirty with symlinks
    file(REAL_PATH "${CMAKE_SOURCE_DIR}" srcdir)
    file(REAL_PATH "${CMAKE_BINARY_DIR}" bindir)

    # Disallow in-source builds
    if("${srcdir}" STREQUAL "${bindir}")
        message("######################################################")
        message("Warning: in-source builds are disabled")
        message("Please create a separate build directory and run cmake from there")
        message("")
        message("Example:")
        message("  mkdir build")
        message("  cd build")
        message("  cmake ..")
        message("")
        message("Or use a preset:")
        message("  cmake --preset <preset-name>")
        message("######################################################")
        message(FATAL_ERROR "Quitting configuration")
    endif()
endfunction()

prevent_in_source_builds()
