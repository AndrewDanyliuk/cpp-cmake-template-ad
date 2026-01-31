# PROJECT_NAME_CAMEL

A modern C++ project template with comprehensive tooling support.

## Features

- ✅ **Modern CMake** (3.23+) with preset support
- ✅ **Multiple C++ standards** (11, 14, 17, 20) - easily configurable
- ✅ **Package managers**: CPM (default) or vcpkg
- ✅ **Testing**: Catch2 (auto-detects v2/v3) backend to CTest. Mock framework: Google Mock
- ✅ **Coverage**: llvm-cov (primary) with gcov/lcov fallback
- ✅ **Pre-commit hooks**: clang-format, clang-tidy, cppcheck run automatically on commit
- ✅ **Static analysis**: clang-tidy, cppcheck (via pre-commit or manual targets)
- ✅ **Code formatting**: clang-format (via pre-commit or manual targets)
- ✅ **Sanitizers**: Address, Thread, Undefined, Memory, Leak
- ✅ **Documentation**: Doxygen with optional modern theme (outputs to `out/docs`)
- ✅ **Compiler caching**: ccache support
- ✅ **Cross-platform**: Linux, macOS, Windows
- ✅ **CI-ready**: GitHub Actions workflow for auto-renaming and auto-formatting

## Quick Start

### Prerequisites

**Required:**
- CMake 3.23 or higher
- C++ compiler (GCC 7+, Clang 6+, MSVC 2019+)
- Ninja (recommended) or Make

**Recommended:**
- pre-commit (for automatic code quality checks on commit)

**Optional:**
- clang-format (for code formatting)
- clang-tidy (for static analysis)
- cppcheck (for static analysis)
- ccache (for faster rebuilds)
- Doxygen (for documentation)
- lcov/gcovr (for coverage HTML reports)

<details>
<summary><b>Installation Instructions</b></summary>

**Ubuntu/Debian:**
```bash
sudo apt-get install cmake ninja-build gcc g++ clang
sudo apt-get install clang-format clang-tidy cppcheck ccache doxygen lcov
pip install pre-commit
```

**macOS:**
```bash
brew install cmake ninja gcc llvm pre-commit
brew install clang-format cppcheck ccache doxygen lcov
```

**Windows:**
```powershell
choco install cmake ninja llvm visualstudio2022buildtools
choco install ccache doxygen.install
pip install pre-commit
```

</details>

### Building the Project

#### Using CMake Presets (Recommended)

```bash
# List available presets
cmake --list-presets

# Configure with a preset
cmake --preset linux-gcc-debug

# Build
cmake --build --preset linux-gcc-debug

# Run tests
ctest --preset linux-gcc-debug
```

#### Using cmake.options (Quick Configuration)

Edit `cmake.options` to set defaults:
Note: options set by a preset will override these.
```ini
CXX_STANDARD=11

BUILD_TYPE=Debug

PACKAGE_MANAGER=CPM

ENABLE_TESTING=ON
ENABLE_COVERAGE=OFF
ENABLE_CPPCHECK=OFF        # Handled by pre-commit
ENABLE_CLANG_TIDY=OFF      # Handled by pre-commit
ENABLE_CLANG_FORMAT=OFF    # Handled by pre-commit
ENABLE_DOXYGEN=OFF
ENABLE_CCACHE=ON
ENABLE_PRE_COMMIT=ON       # Auto-install pre-commit hooks

COVERAGE_TOOL=llvm-cov

ENABLE_SANITIZER_ADDRESS=OFF
ENABLE_SANITIZER_THREAD=OFF
ENABLE_SANITIZER_UNDEFINED=OFF
ENABLE_SANITIZER_MEMORY=OFF
ENABLE_SANITIZER_LEAK=OFF
```

Then build:

```bash
cmake -B build
cmake --build build
ctest --test-dir build
```

#### Manual Configuration

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_STANDARD=11
cmake --build build
ctest --test-dir build --output-on-failure
```

## Available Presets

### Development Presets

| Preset | Description |
|--------|-------------|
| `linux-gcc-debug` | Linux GCC with ccache and pre-commit hooks |
| `linux-gcc-release` | Linux GCC optimized build with tests |
| `linux-clang-debug` | Linux Clang with ccache and pre-commit hooks |
| `linux-clang-release` | Linux Clang optimized build |
| `macos-clang-debug` | macOS Clang with ccache and pre-commit hooks |
| `macos-clang-release` | macOS Clang optimized build |
| `windows-msvc-debug` | Windows MSVC with ccache and pre-commit hooks |
| `windows-msvc-release` | Windows MSVC optimized build |

**Note:** Dev presets use pre-commit for static analysis instead of build-time checks. This avoids duplicate warnings and keeps builds fast.

### Coverage Presets

| Preset | Description |
|--------|-------------|
| `linux-clang-coverage` | Clang with llvm-cov coverage |
| `linux-gcc-coverage` | GCC with gcov coverage |
| `macos-clang-coverage` | macOS with llvm-cov coverage |

### Sanitizer Presets

| Preset | Description |
|--------|-------------|
| `linux-clang-asan` | AddressSanitizer (memory errors) |
| `linux-clang-tsan` | ThreadSanitizer (data races) |
| `linux-clang-ubsan` | UndefinedBehaviorSanitizer |
| `linux-clang-msan` | MemorySanitizer (uninitialized reads) |

### Hardened Release Presets

| Preset | Description |
|--------|-------------|
| `linux-gcc-release-hardened` | GCC Release with hardening + LTO |
| `linux-clang-release-hardened` | Clang Release with hardening + ThinLTO |
| `macos-clang-release-hardened` | macOS Release with hardening + ThinLTO |
| `windows-msvc-release-hardened` | MSVC Release with hardening + LTO |

### Utility Presets

| Preset | Description |
|--------|-------------|
| `format-check` | Check code formatting only |
| `cpp20-linux-clang` | C++20 development build |

## Project Structure

```
PROJECT_NAME/
├── CMakeLists.txt           # Main build configuration
├── CMakePresets.json        # CMake preset definitions
├── cmake.options            # Quick configuration (optional)
├── vcpkg.json               # vcpkg dependencies
├── .clang-format            # Code formatting rules
├── .clang-tidy              # Static analysis rules
├── .pre-commit-config.yaml  # Pre-commit hook configuration
├── cmake/                   # CMake helper modules
│   ├── Coverage.cmake       # Coverage configuration
│   ├── Sanitizers.cmake     # Sanitizer setup
│   ├── Hardening.cmake      # Security hardening flags
│   ├── IPO.cmake            # Link-Time Optimization
│   ├── ClangTidy.cmake      # clang-tidy setup
│   ├── Cppcheck.cmake       # cppcheck setup
│   ├── ClangFormat.cmake    # clang-format targets
│   ├── Ccache.cmake         # Compiler caching
│   ├── Doxygen.cmake        # Documentation generation
│   ├── CPM.cmake            # CPM package manager
│   ├── PreCommit.cmake      # Pre-commit hook installation
│   └── PreventInSourceBuilds.cmake
├── include/                 # Public headers
│   └── PROJECT_NAME_LOWER/
│       └── example.h
├── src/                     # Implementation files
│   ├── CMakeLists.txt
│   └── example.cpp
├── tests/                   # Test files
│   ├── CMakeLists.txt
│   └── test_example.cpp
└── out/                     # Generated output (gitignored except .keep)
    ├── docs/                # Doxygen documentation
    │   └── .keep
    └── coverage/            # Coverage reports
        └── .keep
```

## Configuration Options

### CMake Options

Set via `-D` flag or in `cmake.options`:

| Option | Default | Description |
|--------|---------|-------------|
| `CMAKE_CXX_STANDARD` | 11 | C++ standard (11, 14, 17, 20) |
| `CMAKE_BUILD_TYPE` | Debug | Build type (Debug, Release, RelWithDebInfo) |
| `PACKAGE_MANAGER` | CPM | Package manager (CPM, VCPKG, NONE) |
| `ENABLE_TESTING` | ON | Enable Catch2 tests |
| `ENABLE_COVERAGE` | OFF | Enable coverage reporting |
| `ENABLE_CLANG_TIDY` | OFF | Enable clang-tidy during build (use pre-commit instead) |
| `ENABLE_CPPCHECK` | OFF | Enable cppcheck during build (use pre-commit instead) |
| `ENABLE_CLANG_FORMAT` | OFF | Enable format targets (use pre-commit instead) |
| `ENABLE_PRE_COMMIT` | ON | Auto-install pre-commit hooks on cmake configure |
| `ENABLE_DOXYGEN` | OFF | Enable documentation |
| `ENABLE_CCACHE` | ON | Enable compiler caching |
| `COVERAGE_TOOL` | llvm-cov | Coverage tool (llvm-cov for clang or gcov for gcc/fallback) |
| `ENABLE_SANITIZER_ADDRESS` | OFF | Enable AddressSanitizer |
| `ENABLE_SANITIZER_THREAD` | OFF | Enable ThreadSanitizer |
| `ENABLE_SANITIZER_UNDEFINED` | OFF | Enable UBSan |
| `ENABLE_SANITIZER_MEMORY` | OFF | Enable MemorySanitizer |
| `ENABLE_HARDENING` | OFF | Enable security hardening flags |
| `ENABLE_HARDENING_FULL` | OFF | Enable full hardening (includes spectre mitigations) |
| `ENABLE_IPO` | OFF | Enable Link-Time Optimization |
| `ENABLE_IPO_THIN` | OFF | Use ThinLTO (faster linking) |

### Package Manager Configuration

**CPM (default):**
No additional setup required. Dependencies are automatically downloaded.

**With vcpkg:**
```bash
# Set environment variable
export VCPKG_ROOT=/path/to/vcpkg

# Or in cmake.options
PACKAGE_MANAGER=VCPKG
```

**Note:** vcpkg requires lowercase names with hyphens (not underscores). The rename script automatically converts your project name to vcpkg-compatible format in `vcpkg.json`.

## Testing

### Writing Tests

Create test files in `tests/` directory:

```cpp
#include <catch2/catch_test_macros.hpp>
#include "PROJECT_NAME_LOWER/example.h"

TEST_CASE("My test", "[tag]")
{
    Example ex(42);
    REQUIRE(ex.getValue() == 42);
}
```

### Using Google Mock

```cpp
#include <gmock/gmock.h>

class MockInterface : public Interface
{
public:
    MOCK_METHOD(int, calculate, (int, int), (override));
};

TEST_CASE("Mock example", "[mock]")
{
    MockInterface mock;
    EXPECT_CALL(mock, calculate(2, 3))
        .WillOnce(::testing::Return(5));
    
    REQUIRE(mock.calculate(2, 3) == 5);
}
```

### BDD-Style Tests

```cpp
SCENARIO("Counter behavior", "[example]")
{
    GIVEN("A counter at zero")
    {
        Example counter(0);
        
        WHEN("I increment it")
        {
            counter.add(1);
            
            THEN("It should be one")
            {
                REQUIRE(counter.getValue() == 1);
            }
        }
    }
}
```

### Running Tests

```bash
# Run all tests
ctest --test-dir build

# Run with output
ctest --test-dir build --output-on-failure

# Run specific test
ctest --test-dir build -R "test_name"

# Run in parallel
ctest --test-dir build -j 4
```

## Coverage

Coverage reports are generated to `out/coverage/`.

### Generating Coverage Reports

**With llvm-cov (Clang):**

```bash
# Configure and build
cmake --preset linux-clang-coverage
cmake --build --preset linux-clang-coverage

# Run tests (generates default.profraw)
ctest --preset linux-clang-coverage

# Generate HTML report
cmake --build build/linux-clang-coverage --target coverage-report

# View report
open out/coverage/index.html
```

**With gcov/lcov (GCC):**

```bash
# Configure and build
cmake --preset linux-gcc-coverage
cmake --build --preset linux-gcc-coverage

# Run tests
ctest --preset linux-gcc-coverage

# Generate report (requires lcov)
cmake --build build/linux-gcc-coverage --target coverage-report

# View report
open out/coverage/index.html
```

### Cleaning Coverage Data

```bash
cmake --build build/<preset> --target coverage-clean
```

## Code Formatting & Static Analysis

By default, code formatting (clang-format) and static analysis (clang-tidy, cppcheck) run automatically via **pre-commit hooks** when you commit changes. This keeps builds fast while ensuring code quality.

### Pre-commit Hooks (Default)

Pre-commit hooks are automatically installed when you run `cmake -B build` (if `ENABLE_PRE_COMMIT=ON`).

The following checks run on every commit:
- **clang-format**: Auto-formats staged C/C++ files
- **clang-tidy**: Static analysis using `.clang-tidy` config
- **cppcheck**: Additional static analysis using compile database

```bash
# Manual run on all files
pre-commit run --all-files

# Run specific hook
pre-commit run clang-format --all-files
pre-commit run clang-tidy --all-files
pre-commit run cppcheck --all-files
```

### Manual CMake Targets (Optional)

If you prefer to run these tools via CMake targets instead of pre-commit, enable them:

```bash
cmake -B build -DENABLE_CLANG_FORMAT=ON -DENABLE_CLANG_TIDY=ON -DENABLE_CPPCHECK=ON
```

Then use:
```bash
cmake --build build --target format          # Format all code
cmake --build build --target format-check    # Check formatting (CI)
cmake --build build --target clang-tidy-check
cmake --build build --target cppcheck-check
```

### During-Build Analysis (Not Recommended)

You can enable clang-tidy/cppcheck to run during compilation, but this causes duplicate warnings with GCC and slows builds:

```bash
cmake -B build -DENABLE_CLANG_TIDY=ON -DENABLE_CPPCHECK=ON
```

## Sanitizers

### AddressSanitizer (Memory Errors)

```bash
cmake --preset linux-clang-asan
cmake --build --preset linux-clang-asan
ctest --preset linux-clang-asan
```

### ThreadSanitizer (Data Races)

```bash
cmake --preset linux-clang-tsan
cmake --build --preset linux-clang-tsan
ctest --preset linux-clang-tsan
```

### UndefinedBehaviorSanitizer

```bash
cmake --preset linux-clang-ubsan
cmake --build --preset linux-clang-ubsan
ctest --preset linux-clang-ubsan
```

**Note:** Address and Thread sanitizers cannot be used together.

## Security Hardening

Security hardening applies compiler and linker flags to protect against common exploitation techniques. Best used for production/release builds.

### Standard Hardening

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_HARDENING=ON
cmake --build build
```

**Protections included:**
- **Stack Protection**: `-fstack-protector-strong`, `-fstack-clash-protection`
- **Position Independent Code**: PIE for executables, PIC for libraries
- **Format String Protection**: `-Wformat-security`, `-Werror=format-security`
- **FORTIFY_SOURCE**: Runtime buffer overflow detection
- **RELRO**: Full relocation read-only (`-Wl,-z,relro,-z,now`)
- **Control Flow Integrity**: `-fcf-protection=full` (x86), `-mbranch-protection` (ARM)
- **Non-executable Stack**: `-Wl,-z,noexecstack`

### Full Hardening (Maximum Security)

Includes additional speculative execution mitigations. **May impact performance.**

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_HARDENING=ON -DENABLE_HARDENING_FULL=ON
cmake --build build
```

**Additional protections:**
- **Spectre Mitigations**: `-mretpoline`, `-mspeculative-load-hardening`
- **Register Clearing**: `-fzero-call-used-regs`
- **SLS Hardening**: `-mharden-sls=all`
- **Intel CET**: `-Wl,-z,ibt`, `-Wl,-z,shstk` (Linux)

### Hardened Release Presets

```bash
# Linux GCC with hardening + LTO
cmake --preset linux-gcc-release-hardened
cmake --build --preset linux-gcc-release-hardened

# Linux Clang with hardening + ThinLTO
cmake --preset linux-clang-release-hardened
cmake --build --preset linux-clang-release-hardened

# macOS with hardening + ThinLTO
cmake --preset macos-clang-release-hardened
cmake --build --preset macos-clang-release-hardened

# Windows MSVC with hardening + LTO
cmake --preset windows-msvc-release-hardened
cmake --build --preset windows-msvc-release-hardened
```

## Link-Time Optimization (LTO)

LTO enables whole-program optimization by deferring optimization decisions to link time, typically providing 5-20% performance improvement.

### When to Use LTO

| Build Type | Recommended | Notes |
|------------|-------------|-------|
| Debug | No | Increases link time, breaks debugging |
| Release | Yes | Best performance for production |
| CI/Testing | ThinLTO | Faster than full LTO |

### Standard LTO

Maximum optimization, but slower linking:

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_IPO=ON
cmake --build build
```

### ThinLTO (Recommended for Development)

Faster linking with most of the optimization benefits:

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_IPO=ON -DENABLE_IPO_THIN=ON
cmake --build build
```

**Comparison:**

| Feature | Full LTO | ThinLTO |
|---------|----------|---------|
| Optimization | Maximum | ~95% of full |
| Link Time | Slow (2-10x) | Moderate (1.5-3x) |
| Memory Usage | High | Lower |
| Incremental Builds | Poor | Better |
| Clang Support | Yes | Yes (preferred) |
| GCC Support | Yes | No (uses parallel LTO) |

## Documentation

Documentation is generated to `out/docs/`.

### Generate Doxygen Docs

```bash
cmake -B build -DENABLE_DOXYGEN=ON
cmake --build build --target docs
open out/docs/index.html
```

### Modern Doxygen Theme

Set in CMakeLists.txt:
```cmake
set(DOXYGEN_THEME "awesome-sidebar" CACHE STRING "")
```

Options: `none`, `awesome`, `awesome-sidebar`

## Modifying the Project

### Adding New Source Files

Edit `src/CMakeLists.txt`:

```cmake
add_library(${PROJECT_NAME}_lib
    example.cpp
    new_file.cpp  # Add here
)
```

### Adding New Tests

1. Create test file in `tests/`:
```cpp
// tests/test_new_feature.cpp
#include <catch2/catch_test_macros.hpp>

TEST_CASE("New feature test", "[new]")
{
    // Test code
}
```

2. Edit `tests/CMakeLists.txt`:
```cmake
add_executable(${PROJECT_NAME}_tests
    test_example.cpp
    test_new_feature.cpp  # Add here
)
```

### Adding Dependencies

**With CPM:**

Edit main `CMakeLists.txt`:
```cmake
CPMAddPackage("gh:fmtlib/fmt#10.2.1")
CPMAddPackage(
    NAME nlohmann_json
    GITHUB_REPOSITORY nlohmann/json
    VERSION 3.11.3
)

target_link_libraries(${PROJECT_NAME}_lib
    PUBLIC
        fmt::fmt
        nlohmann_json::nlohmann_json
)
```

**With vcpkg:**

Edit `vcpkg.json`:
```json
{
  "dependencies": [
    "catch2",
    "gtest",
    "fmt",
    "nlohmann-json"
  ]
}
```

### Changing C++ Standard

**Option 1: cmake.options**
```ini
CXX_STANDARD=20
```

**Option 2: CMake command line**
```bash
cmake -B build -DCMAKE_CXX_STANDARD=20
```

**Option 3: Use preset**
```bash
cmake --preset cpp20-linux-clang
```

## Troubleshooting

### "Catch module not found"

The template automatically uses:
- **Catch2 v2** for C++11 projects
- **Catch2 v3** for C++14+ projects

If you see `include could not find requested file: Catch`, ensure your C++ standard is set correctly in `cmake.options` or your preset.

### "Compiler not found"

Set compiler explicitly:
```bash
cmake -B build -DCMAKE_CXX_COMPILER=g++-11
```

Or use a preset that specifies the compiler.

### "vcpkg not found"

If using vcpkg, set `VCPKG_ROOT`:
```bash
export VCPKG_ROOT=/path/to/vcpkg
```

Or use CPM instead (default).

### "clang-tidy errors during build"

By default, clang-tidy runs via pre-commit, not during build. If you've enabled build-time analysis:
```bash
cmake -B build -DENABLE_CLANG_TIDY=OFF
```

Or fix the issues (recommended).

### "pre-commit not found"

Install pre-commit:
```bash
pip install pre-commit
```

Or disable automatic hook installation:
```bash
cmake -B build -DENABLE_PRE_COMMIT=OFF
```

### "pre-commit hooks failing"

Ensure you've built the project at least once (creates `compile_commands.json`):
```bash
cmake -B build && cmake --build build
```

Then run pre-commit:
```bash
pre-commit run --all-files
```

### "Coverage not working"

Ensure you're using Debug build:
```bash
cmake --preset linux-clang-coverage  # Includes CMAKE_BUILD_TYPE=Debug
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: CI
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install tools
        run: |
          sudo apt-get update
          sudo apt-get install -y ninja-build clang clang-format clang-tidy cppcheck
          pip install pre-commit

      - name: Configure (generates compile_commands.json)
        run: cmake -B build -DENABLE_PRE_COMMIT=OFF

      - name: Run pre-commit
        run: pre-commit run --all-files

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y ninja-build clang

      - name: Configure
        run: cmake --preset linux-clang-debug

      - name: Build
        run: cmake --build --preset linux-clang-debug

      - name: Test
        run: ctest --preset linux-clang-debug
```

## Resources
### Testing
Using mock frameworks for testing: [CFD University Software Testing Guide: Mocks](https://cfd.university/learn/the-complete-guide-to-software-testing-for-cfd-applications/how-to-use-mocking-in-cfd-test-code-using-gtest-and-gmock/#aioseo-parameter-reading-files)

## License

[Choose your license]

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and formatting
5. Submit a pull request

## Credits

This template uses:
- [CMake](https://cmake.org/)
- [Catch2](https://github.com/catchorg/Catch2)
- [Google Test/Mock](https://github.com/google/googletest)
- [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake)
- [pre-commit](https://pre-commit.com/)
