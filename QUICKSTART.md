# Quick Start Guide

Get up and running in 5 minutes!

## 1. Create Project from Template

**On GitHub:**
1. Click "Use this template" button
2. Name your new repository
3. Wait for the automatic rename workflow to complete (~1 minute)

**Or locally:**
```bash
git clone https://github.com/YOUR_USERNAME/cpp-template my-project
cd my-project
./scripts/rename_project.sh my-project
```

## 2. Install Prerequisites

**Ubuntu/Debian:**
```bash
sudo apt-get install cmake ninja-build g++ clang
```

**macOS:**
```bash
brew install cmake ninja llvm
```

**Windows:**
```powershell
choco install cmake ninja llvm visualstudio2022buildtools
```

## 1. Configure and Build

Every build starts with choosing a **preset**. Presets define the compiler, build type, and platform.

```bash
# List available presets for your platform
cmake --list-presets

# Configure (pick one for your OS)
cmake --preset macos-clang-debug     # macOS
cmake --preset linux-gcc-debug       # Linux (GCC)
cmake --preset linux-clang-debug     # Linux (Clang)
cmake --preset windows-msvc-debug    # Windows

# Build
cmake --build build/<preset-name>
```

### Which preset should I use?

| Goal | Preset |
|---|---|
| Day-to-day development (macOS) | `macos-clang-debug` |
| Day-to-day development (Linux, GCC) | `linux-gcc-debug` |
| Day-to-day development (Linux, Clang) | `linux-clang-debug` |
| Day-to-day development (Windows) | `windows-msvc-debug` |
| Code coverage (macOS/Linux Clang) | `macos-clang-coverage` / `linux-clang-coverage` |
| Code coverage (Linux GCC) | `linux-gcc-coverage` |
| AddressSanitizer (Linux) | `linux-clang-asan` |
| ThreadSanitizer (Linux) | `linux-clang-tsan` |
| UBSanitizer (Linux) | `linux-clang-ubsan` |
| MemorySanitizer (Linux) | `linux-clang-msan` |
| Release build | `<os>-<compiler>-release` |
| Hardened release + LTO | `<os>-<compiler>-release-hardened` |

**Debug presets** include `dev-mode` which enables: testing, ccache, and disables static analysis by default.
**Release presets** enable testing but omit dev tooling.

## 2. Configuration Precedence

Settings can be changed in multiple places. Higher precedence wins:

1. **Command line** (highest): `cmake -B build -DENABLE_TESTING=ON`
2. **CMakePresets.json**: `cacheVariables` in the selected preset
3. **cmake.options**: quick-toggle defaults file (edit this for local tweaks)
4. **CMakeLists.txt**: hardcoded fallback defaults (lowest)

For quick experimentation, edit `cmake.options`. For reproducible/CI builds, use presets.

## 3. Project Structure

```
src/
    CMakeLists.txt          # Library and executable targets
    questions1.cpp          # Source files
    ...
include/
    <project_name>/
        assign4.h           # Public headers
tests/
    CMakeLists.txt          # Test target
    test_example.cpp        # Test files (Catch2)
cmake.options               # Quick config toggles
CMakePresets.json            # Preset definitions
```

## 4. Adding Source Files

### Adding to the library

1. Create your `.cpp` file in `src/`
2. Add it to the `add_library()` call in `src/CMakeLists.txt`:

```cmake
add_library(${PROJECT_NAME}_lib
    questions1.cpp
    my_new_file.cpp          # <-- add here
)
```

3. Declare functions/classes in a header under `include/<project_name>/`

**If you forget to add a `.cpp` file here, you'll get a linker error** ("undefined symbol") even though the code compiles fine.

### Creating an executable

Uncomment the block at the bottom of `src/CMakeLists.txt`:

```cmake
add_executable(${PROJECT_NAME}
    main.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        ${PROJECT_NAME}::lib
)
```

Then create `src/main.cpp` with a `main()` function.

### Adding tests

1. Write your test file in `tests/` using Catch2:

```cpp
// Catch2 v2 (C++11) -- this project uses v2
#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>
#include "<project_name>/your_header.h"

TEST_CASE("My test", "[tag]") {
    REQUIRE(1 + 1 == 2);
}
```

2. Add the file to `tests/CMakeLists.txt`:

```cmake
add_executable(${PROJECT_NAME}_tests
    test_example.cpp
    test_my_new_file.cpp     # <-- add here
)
```

Note: This project uses **Catch2 v2** (for C++11 compatibility). If `CXX_STANDARD` is set to 14 or higher, Catch2 v3 is used automatically.

## 5. Running Tests

```bash
# Run all tests
ctest --test-dir build/<preset-name>

# Run with output on failure
ctest --test-dir build/<preset-name> --output-on-failure

# Run a specific test by name
ctest --test-dir build/<preset-name> -R "test name pattern"
```

## 6. Code Coverage

Coverage requires `ENABLE_COVERAGE=ON` (set in `cmake.options` or use a coverage preset).

```bash
# Option A: Use a coverage preset
cmake --preset macos-clang-coverage
cmake --build build/macos-clang-coverage

# Option B: Use cmake.options (already ON by default in this project)
# Just build with your normal debug preset

# Step 1: Run tests (generates .profraw)
ctest --test-dir build/<preset-name>

# Step 2: Generate HTML report
cmake --build build/<preset-name> --target coverage-report

# Step 3: View
open out/coverage/index.html
```

The coverage report is written to `out/coverage/`.

## 7. Sanitizers

Sanitizers detect runtime bugs. Enable them in `cmake.options`:

```ini
ENABLE_SANITIZER_ADDRESS=ON      # buffer overflows, use-after-free, double-free
ENABLE_SANITIZER_THREAD=ON       # data races (conflicts with address)
ENABLE_SANITIZER_UNDEFINED=ON    # undefined behavior
ENABLE_SANITIZER_MEMORY=ON       # uninitialized reads (Clang-only, Linux-only)
ENABLE_SANITIZER_LEAK=ON         # memory leaks (Linux-only)
```

Or use a sanitizer preset (Linux):

```bash
cmake --preset linux-clang-asan    # AddressSanitizer
cmake --preset linux-clang-tsan    # ThreadSanitizer
cmake --preset linux-clang-ubsan   # UndefinedBehaviorSanitizer
cmake --preset linux-clang-msan    # MemorySanitizer
```

Sanitizers produce output **only when they detect a problem**. No output = no bugs found.

**Important constraints:**
- Address and Thread sanitizers cannot be used together
- Leak sanitizer does not work on macOS (use `check-leaks` target instead)
- Memory sanitizer is Linux + Clang only

### Memory Leak Detection on macOS

This project includes a `check-leaks` CMake target that uses macOS's native `leaks` tool. It is **incompatible with AddressSanitizer** -- you must disable ASan first:

```ini
# In cmake.options, set:
ENABLE_SANITIZER_ADDRESS=OFF
```

Then reconfigure, rebuild, and run:

```bash
cmake --preset macos-clang-debug
cmake --build build/macos-clang-debug
cmake --build build/macos-clang-debug --target check-leaks
```

## 8. cmake.options Reference

| Option | Default | Description |
|---|---|---|
| `CXX_STANDARD` | `11` | C++ standard (11, 14, 17, 20, 23) |
| `BUILD_TYPE` | `Debug` | Build type (Debug, Release, RelWithDebInfo, MinSizeRel) |
| `PACKAGE_MANAGER` | `CPM` | Dependency manager (CPM, VCPKG, NONE) |
| `ENABLE_TESTING` | `ON` | Build and run Catch2 tests |
| `ENABLE_COVERAGE` | `ON` | Instrument for code coverage |
| `COVERAGE_TOOL` | `llvm-cov` | Coverage backend (llvm-cov or gcov) |
| `ENABLE_CCACHE` | `ON` | Use ccache for faster rebuilds |
| `ENABLE_CPPCHECK` | `OFF` | Static analysis with cppcheck |
| `ENABLE_CLANG_TIDY` | `OFF` | Static analysis with clang-tidy |
| `ENABLE_CLANG_FORMAT` | `OFF` | Code formatting targets |
| `ENABLE_DOXYGEN` | `OFF` | Generate documentation |
| `ENABLE_SANITIZER_ADDRESS` | `OFF` | AddressSanitizer |
| `ENABLE_SANITIZER_THREAD` | `OFF` | ThreadSanitizer |
| `ENABLE_SANITIZER_UNDEFINED` | `OFF` | UBSan |
| `ENABLE_SANITIZER_MEMORY` | `OFF` | MemorySanitizer |
| `ENABLE_SANITIZER_LEAK` | `OFF` | LeakSanitizer |
| `ENABLE_HARDENING` | `OFF` | Security hardening flags |
| `ENABLE_HARDENING_FULL` | `OFF` | + speculative execution mitigations |
| `ENABLE_IPO` | `OFF` | Link-Time Optimization |
| `ENABLE_IPO_THIN` | `OFF` | ThinLTO (faster than full LTO) |

## 9. Custom CMake Targets

| Target | Description |
|---|---|
| `coverage-report` | Generate HTML coverage report to `out/coverage/` |
| `coverage-clean` | Delete all coverage data |
| `check-leaks` | Run macOS `leaks` tool (requires ASan OFF) |
| `format` | Format code with clang-format (requires `ENABLE_CLANG_FORMAT=ON`) |
