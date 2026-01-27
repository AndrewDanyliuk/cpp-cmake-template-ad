================================================================================
CATCH2 VERSION COMPATIBILITY
================================================================================

AUTOMATIC VERSION SELECTION
============================

The template automatically selects the correct Catch2 version based on your
C++ standard:

C++11 → Catch2 v2.13.10
C++14+ → Catch2 v3.5.2

This happens in CMakeLists.txt:

```cmake
if(CMAKE_CXX_STANDARD EQUAL 11)
    CPMAddPackage("gh:catchorg/Catch2@2.13.10")
else()
    CPMAddPackage("gh:catchorg/Catch2@3.5.2")
endif()
```


WHY TWO VERSIONS?
=================

Catch2 v3 Requirements:
-----------------------
- Requires C++14 or higher
- Uses modern C++ features
- Better performance
- Improved API

Catch2 v2 Support:
------------------
- Works with C++11
- Older but stable
- Widely used in legacy projects


KEY DIFFERENCES
===============

Include Path:
-------------
Both versions use the same include:
#include <catch2/catch_test_macros.hpp>

Module Name:
------------
Catch2 v3: include(Catch)
Catch2 v2: include(ParseAndAddCatchTests) or include(Catch)

Target Name:
------------
Both: Catch2::Catch2WithMain


TESTS/CMAKELISTS.TXT HANDLES BOTH
==================================

The tests/CMakeLists.txt automatically detects which version is available:

```cmake
# Try Catch2 v3 style first
if(EXISTS "${Catch2_SOURCE_DIR}/extras/Catch.cmake")
    include("${Catch2_SOURCE_DIR}/extras/Catch.cmake")
    catch_discover_tests(${PROJECT_NAME}_tests)
elseif(EXISTS "${Catch2_SOURCE_DIR}/contrib/Catch.cmake")
    include("${Catch2_SOURCE_DIR}/contrib/Catch.cmake")
    catch_discover_tests(${PROJECT_NAME}_tests)
else()
    # Manual test registration as fallback
    add_test(NAME ${PROJECT_NAME}_tests COMMAND ${PROJECT_NAME}_tests)
endif()
```


CHANGING C++ STANDARD
======================

If you change the C++ standard, you need to reconfigure:

```bash
# Change in cmake.options
CXX_STANDARD=14

# Or use command line
cmake -B build -DCMAKE_CXX_STANDARD=14

# Or use preset
cmake --preset cpp20-linux-clang
```

Then clean and rebuild:
```bash
rm -rf build
cmake --preset linux-gcc-debug
cmake --build --preset linux-gcc-debug
```


VCPKG USERS
===========

If using vcpkg, it will download the version available in vcpkg:

```bash
# vcpkg provides both versions
vcpkg install catch2       # Latest (v3)
vcpkg install catch2:x64-windows-static-md  # Specific version
```

The template tries v3 first, falls back to v2:

```cmake
find_package(Catch2 3 QUIET)
if(NOT Catch2_FOUND)
    find_package(Catch2 2 REQUIRED)
endif()
```


TROUBLESHOOTING
===============

Error: "include could not find requested file: Catch"
------------------------------------------------------
Cause: CMake can't find the Catch module file

Solution 1 - Check C++ standard:
```bash
cmake -B build -LA | grep CMAKE_CXX_STANDARD
# Should show 11, 14, 17, or 20
```

Solution 2 - Force reconfigure:
```bash
rm -rf build
cmake -B build
```

Solution 3 - Check Catch2 was downloaded:
```bash
ls build/_deps/catch2-*
# Should show catch2-src and catch2-build directories
```


Error: "Target Catch2::Catch2WithMain not found"
-------------------------------------------------
Cause: Catch2 wasn't downloaded/found

Solution - Check package manager:
```bash
cmake -B build -LA | grep PACKAGE_MANAGER
# Should show CPM or VCPKG
```

If CPM: Check internet connection (CPM downloads from GitHub)
If VCPKG: Check VCPKG_ROOT is set and vcpkg installed


MANUAL OVERRIDE
===============

If you want to force a specific version regardless of C++ standard:

Edit CMakeLists.txt:
```cmake
# Force Catch2 v3
CPMAddPackage("gh:catchorg/Catch2@3.5.2")

# Or force Catch2 v2
CPMAddPackage("gh:catchorg/Catch2@2.13.10")
```


FEATURE COMPATIBILITY
=====================

Feature                  | Catch2 v2 | Catch2 v3
-------------------------|-----------|----------
TEST_CASE                | ✓         | ✓
SECTION                  | ✓         | ✓
REQUIRE/CHECK            | ✓         | ✓
SCENARIO/GIVEN/WHEN/THEN | ✓         | ✓
Matchers                 | ✓         | ✓ (more)
BDD macros               | ✓         | ✓
catch_discover_tests     | ✓         | ✓
C++11 support            | ✓         | ✗
C++14 required           | ✗         | ✓
Modern features          | Limited   | Full


TEST CODE COMPATIBILITY
=======================

All test code in the template works with both versions:

```cpp
TEST_CASE("Example", "[tag]")
{
    REQUIRE(1 + 1 == 2);
}

SCENARIO("BDD style", "[bdd]")
{
    GIVEN("A value")
    {
        int x = 5;
        WHEN("We double it")
        {
            x *= 2;
            THEN("It should be 10")
            {
                REQUIRE(x == 10);
            }
        }
    }
}
```

This code works identically in Catch2 v2 and v3!


RECOMMENDATION
==============

For new projects:
-----------------
Use C++17 or C++20 → Gets Catch2 v3 automatically
Benefits: Better performance, modern API, active development

For legacy projects:
--------------------
Stick with C++11 → Gets Catch2 v2 automatically
Benefits: Stability, known behavior, wider compiler support


SUMMARY
=======

✓ Template handles both Catch2 versions automatically
✓ Selection based on CMAKE_CXX_STANDARD
✓ Tests work with both versions
✓ No manual configuration needed
✓ Easy to override if needed

The automatic detection means you don't have to think about it - just set
your C++ standard and the template does the rest!
