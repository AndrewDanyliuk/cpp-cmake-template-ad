# Pre-commit hook installation
# Automatically installs pre-commit hooks when configuring the project

option(ENABLE_PRE_COMMIT "Install pre-commit hooks during configuration" ON)

function(setup_pre_commit)
    if(NOT ENABLE_PRE_COMMIT)
        return()
    endif()

    # Only run in the top-level project
    if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
        return()
    endif()

    # Check if .pre-commit-config.yaml exists
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/.pre-commit-config.yaml")
        message(STATUS "Pre-commit: No .pre-commit-config.yaml found, skipping")
        return()
    endif()

    # Check if this is a git repository
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/.git")
        message(STATUS "Pre-commit: Not a git repository, skipping")
        return()
    endif()

    # Find pre-commit executable
    find_program(PRE_COMMIT_EXECUTABLE pre-commit)

    if(NOT PRE_COMMIT_EXECUTABLE)
        message(STATUS "Pre-commit: executable not found. Install with: pip install pre-commit")
        return()
    endif()

    # Check if hooks are already installed
    if(EXISTS "${CMAKE_SOURCE_DIR}/.git/hooks/pre-commit")
        file(READ "${CMAKE_SOURCE_DIR}/.git/hooks/pre-commit" HOOK_CONTENT)
        if(HOOK_CONTENT MATCHES "pre-commit")
            message(STATUS "Pre-commit: hooks already installed")
            return()
        endif()
    endif()

    # Install pre-commit hooks
    message(STATUS "Pre-commit: installing hooks...")
    execute_process(
        COMMAND ${PRE_COMMIT_EXECUTABLE} install
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE RESULT
        OUTPUT_QUIET
        ERROR_QUIET
    )

    if(RESULT EQUAL 0)
        message(STATUS "Pre-commit: hooks installed successfully")
    else()
        message(WARNING "Pre-commit: failed to install hooks (exit code: ${RESULT})")
    endif()
endfunction()
