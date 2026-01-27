================================================================================
FINAL TEMPLATE STRUCTURE
================================================================================

cpp-template/
├── .clang-format                    # Code formatting configuration (Allman style)
├── .clang-tidy                      # Static analysis rules
├── .gitignore                       # Git ignore patterns
├── CMakeLists.txt                   # Main build configuration (modular, 150 lines)
├── CMakePresets.json                # 20+ build presets for all platforms
├── cmake.options                    # Quick configuration with clear precedence
├── LICENSE                          # MIT license template
├── QUICKSTART.md                    # 5-minute getting started guide
├── README.md                        # Comprehensive documentation (500+ lines)
├── vcpkg.json                       # vcpkg dependencies (with schema)
│
├── .github/
│   └── workflows/
│       └── rename-project.yml       # Auto-rename on repository creation
│
├── cmake/                           # Modular CMake helper files
│   ├── CPM.cmake                    # CPM package manager setup
│   ├── Ccache.cmake                 # Compiler caching
│   ├── ClangFormat.cmake            # Code formatting targets
│   ├── ClangTidy.cmake              # Static analysis setup
│   ├── Coverage.cmake               # llvm-cov + gcov fallback
│   ├── Cppcheck.cmake               # Alternative static analysis
│   ├── Doxygen.cmake                # Documentation with modern theme
│   ├── PreventInSourceBuilds.cmake  # Prevent in-source builds
│   └── Sanitizers.cmake             # Runtime sanitizers
│
├── include/
│   └── PROJECT_NAME_LOWER/          # Public headers (will be renamed)
│       └── example.h                # Example header with Doxygen comments
│
├── scripts/
│   └── rename_project.sh            # Manual rename script (executable)
│
├── src/
│   ├── CMakeLists.txt               # Library/executable definition
│   └── example.cpp                  # Example implementation
│
└── tests/
    ├── CMakeLists.txt               # Test configuration
    └── test_example.cpp             # Comprehensive test examples
                                      # - Basic Catch2 tests
                                      # - BDD-style (SCENARIO/GIVEN/WHEN/THEN)
                                      # - Google Mock examples
                                      # - Test fixtures


AFTER RUNNING RENAME SCRIPT
============================

Example: ./scripts/rename_project.sh my-robot-controller

my-robot-controller/
├── include/
│   └── my_robot_controller/         # Renamed from PROJECT_NAME_LOWER
│       └── example.h                # Updated with correct namespace
├── src/
│   └── example.cpp                  # Updated namespace
└── tests/
    └── test_example.cpp             # Updated namespace

All files updated with:
- Namespace: my_robot_controller
- Header guards: MY_ROBOT_CONTROLLER_*
- CMake project: MyRobotController
- vcpkg name: my-robot-controller


DIRECTORY PURPOSES
==================

.github/workflows/
------------------
GitHub Actions workflows. Currently contains auto-rename workflow that
triggers on first push to main/master branch.

cmake/
------
Modular CMake helper files. Each file is self-contained and documented.
Delete files you don't need (e.g., delete Doxygen.cmake if not using docs).

include/PROJECT_NAME_LOWER/
---------------------------
Public API headers. Directory name matches C++ namespace (lowercase with
underscores). Will be renamed by script.

scripts/
--------
Utility scripts. Currently contains rename_project.sh which should be
removed after first run (automatic if using GitHub Actions).

src/
----
Implementation files. Keep all .cpp files here. Update src/CMakeLists.txt
when adding new files.

tests/
------
Unit tests using Catch2 and Google Mock. Update tests/CMakeLists.txt when
adding new test files.


VERIFICATION
============

To verify the template structure is correct:

1. Count files: should be 26
   find . -type f | wc -l

2. Check for artifacts: should be empty
   find . -type d -name "{*"

3. Verify executables:
   ls -l scripts/rename_project.sh  # Should have +x flag

4. Verify CMake modules:
   ls cmake/*.cmake  # Should show 9 files

5. Test build (requires CMake 3.23+):
   cmake --list-presets
   cmake --preset linux-gcc-debug
   cmake --build --preset linux-gcc-debug


COMMON QUESTIONS
================

Q: Why PROJECT_NAME_LOWER directory?
A: Placeholder that matches C++ namespace convention (snake_case).
   The rename script converts this to your actual project name.

Q: Why separate cmake/ files?
A: Modularity. Delete what you don't need. Each file is self-documenting.

Q: Why both cmake.options and CMakePresets.json?
A: cmake.options = quick defaults for beginners
   CMakePresets.json = powerful presets for advanced users
   Both work together with clear precedence rules.

Q: Can I rename manually?
A: Yes, run: ./scripts/rename_project.sh your-project-name
   Or let GitHub Actions do it automatically.


NEXT STEPS AFTER EXTRACTION
============================

1. Extract archive: tar -xzf cpp-template.tar.gz
2. Optional: Rename project: ./scripts/rename_project.sh my-project
3. Initialize git: git init && git add . && git commit -m "Initial commit"
4. Test build: cmake --preset linux-gcc-debug
5. Run tests: ctest --preset linux-gcc-debug
6. Start coding!