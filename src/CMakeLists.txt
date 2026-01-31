# Compiler warnings (applied only to project targets, not dependencies)
include(${PROJECT_SOURCE_DIR}/cmake/CompilerWarnings.cmake)

# Library target
add_library(${PROJECT_NAME}_lib
    example.cpp
)

# Add alias for consistent naming
add_library(${PROJECT_NAME}::lib ALIAS ${PROJECT_NAME}_lib)

target_include_directories(${PROJECT_NAME}_lib
    PUBLIC
        ${PROJECT_SOURCE_DIR}/include
)

target_compile_features(${PROJECT_NAME}_lib
    PUBLIC
        cxx_std_${CMAKE_CXX_STANDARD}
)

# Apply strict warnings to this target only
set_project_warnings(${PROJECT_NAME}_lib)

# Apply security hardening if enabled
if(ENABLE_HARDENING)
    harden(${PROJECT_NAME}_lib)
endif()

# Optional: Add other libs you want warnings for here

# Optional: Create an executable
# Uncomment if you want a main executable
# add_executable(${PROJECT_NAME}
#     main.cpp
# )
# 
# target_link_libraries(${PROJECT_NAME}
#     PRIVATE
#         ${PROJECT_NAME}::lib
# )
