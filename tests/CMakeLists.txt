# Test executable
add_executable(${PROJECT_NAME}_tests
    test_example.cpp
)

target_link_libraries(${PROJECT_NAME}_tests
    PRIVATE
        ${PROJECT_NAME}::lib
        Catch2::Catch2WithMain
        gmock
)

# Discover and register tests with CTest
list(APPEND CMAKE_MODULE_PATH ${Catch2_SOURCE_DIR}/extras)
include(Catch)
catch_discover_tests(${PROJECT_NAME}_tests)
