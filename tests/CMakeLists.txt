# Compiler warnings (applied only to project targets, not dependencies)
include(${PROJECT_SOURCE_DIR}/cmake/CompilerWarnings.cmake)

# Test executable
add_executable(${PROJECT_NAME}_tests
    test_example.cpp
)

# Detect Catch2 version: v3 has Catch2WithMain target, v2 does not
if(TARGET Catch2::Catch2WithMain)
    set(CATCH2_TARGET Catch2::Catch2WithMain)
    set(CATCH2_VERSION 3)
else()
    set(CATCH2_TARGET Catch2::Catch2)
    set(CATCH2_VERSION 2)
endif()

target_link_libraries(${PROJECT_NAME}_tests
    PRIVATE
        ${PROJECT_NAME}::lib
        ${CATCH2_TARGET}
        gmock
)

# Pass Catch2 version to source code for conditional includes
target_compile_definitions(${PROJECT_NAME}_tests PRIVATE CATCH2_VERSION=${CATCH2_VERSION})

# Apply strict warnings to this target only
set_project_warnings(${PROJECT_NAME}_tests)

# Apply security hardening if enabled
if(ENABLE_HARDENING)
    harden(${PROJECT_NAME}_tests)
endif()

# Enable CTest support
include(CTest)
enable_testing()

# Add Catch2 module path (v2 uses contrib/, v3 uses extras/)
if(EXISTS "${Catch2_SOURCE_DIR}/extras")
    list(APPEND CMAKE_MODULE_PATH "${Catch2_SOURCE_DIR}/extras")
elseif(EXISTS "${Catch2_SOURCE_DIR}/contrib")
    list(APPEND CMAKE_MODULE_PATH "${Catch2_SOURCE_DIR}/contrib")
endif()

include(Catch)
catch_discover_tests(${PROJECT_NAME}_tests)
