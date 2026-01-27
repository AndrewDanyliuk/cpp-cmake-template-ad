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

## 3. Build and Test

```bash
# Configure with preset
cmake --preset linux-gcc-debug

# Build
cmake --build --preset linux-gcc-debug

# Run tests
ctest --preset linux-gcc-debug
```

## 4. Start Coding!

### Add a new class:

**include/myproject/calculator.h:**
```cpp
#ifndef MYPROJECT_CALCULATOR_H
#define MYPROJECT_CALCULATOR_H

namespace myproject {

class Calculator
{
public:
    int add(int a, int b);
};

}  // namespace myproject

#endif
```

**src/calculator.cpp:**
```cpp
#include "myproject/calculator.h"

namespace myproject {

int Calculator::add(int a, int b)
{
    return a + b;
}

}  // namespace myproject
```

**Update src/CMakeLists.txt:**
```cmake
add_library(${PROJECT_NAME}_lib
    example.cpp
    calculator.cpp  # Add this line
)
```

### Add a test:

**tests/test_calculator.cpp:**
```cpp
#include <catch2/catch_test_macros.hpp>
#include "myproject/calculator.h"

TEST_CASE("Calculator adds numbers", "[calc]")
{
    myproject::Calculator calc;
    REQUIRE(calc.add(2, 3) == 5);
}
```

**Update tests/CMakeLists.txt:**
```cmake
add_executable(${PROJECT_NAME}_tests
    test_example.cpp
    test_calculator.cpp  # Add this line
)
```

### Rebuild and test:

```bash
cmake --build --preset linux-gcc-debug
ctest --preset linux-gcc-debug
```

## 5. Common Tasks

### Change C++ standard to C++20:

**Edit cmake.options:**
```ini
CXX_STANDARD=20
```

**Or use preset:**
```bash
cmake --preset cpp20-linux-clang
```

### Enable code coverage:

```bash
cmake --preset linux-clang-coverage
cmake --build --preset linux-clang-coverage
ctest --preset linux-clang-coverage

# Generate report
llvm-profdata merge -sparse default.profraw -o default.profdata
llvm-cov show ./build/linux-clang-coverage/tests/*_tests \
  -instr-profile=default.profdata \
  -format=html \
  -output-dir=coverage

open coverage/index.html
```

### Format code:

```bash
cmake -B build -DENABLE_CLANG_FORMAT=ON
cmake --build build --target format
```

### Run static analysis:

```bash
cmake --preset linux-clang-debug  # Includes clang-tidy
cmake --build --preset linux-clang-debug
```

## 6. Available Presets

List all presets:
```bash
cmake --list-presets
```

Common presets:
- `linux-gcc-debug` - Development with GCC
- `linux-clang-debug` - Development with Clang
- `linux-clang-coverage` - Code coverage with llvm-cov
- `linux-clang-asan` - AddressSanitizer (memory errors)
- `linux-clang-tsan` - ThreadSanitizer (data races)
- `macos-clang-debug` - macOS development
- `windows-msvc-debug` - Windows MSVC

## Need Help?

- See [README.md](README.md) for comprehensive documentation
- Check the `cmake/` directory for configuration modules
- Edit `cmake.options` for quick configuration changes
- Use presets for reproducible builds

## Next Steps

1. Update [README.md](README.md) with your project description
2. Choose a license in [LICENSE](LICENSE)
3. Add dependencies to `CMakeLists.txt` or `vcpkg.json`
4. Write tests as you add features
5. Enable CI/CD (see README for GitHub Actions example)

Happy coding! 🚀
