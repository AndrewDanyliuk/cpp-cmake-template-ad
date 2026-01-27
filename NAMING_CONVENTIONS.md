================================================================================
PROJECT NAMING CONVENTIONS
================================================================================

When the rename script runs, it creates several variants of your project name
to satisfy different requirements:

EXAMPLE: Input name "MyAwesomeProject"
=======================================

1. PROJECT_NAME_CAMEL → MyAwesomeProject
   Used for: CMake project() name, display names
   Format: PascalCase (no separators)

2. PROJECT_NAME_LOWER → my_awesome_project
   Used for: C++ namespaces, include directories, library names
   Format: snake_case (underscores)

3. PROJECT_NAME_UPPER → MY_AWESOME_PROJECT
   Used for: Header guards, preprocessor defines
   Format: SCREAMING_SNAKE_CASE (underscores)

4. project-name → my-awesome-project
   Used for: vcpkg package name (vcpkg.json)
   Format: kebab-case (hyphens)
   
   ⚠️ IMPORTANT: vcpkg requires lowercase with hyphens, not underscores
   The rename script automatically handles this conversion.


WHY DIFFERENT FORMATS?
=======================

C++ Namespace (snake_case):
----------------------------
namespace my_awesome_project {
    class Example { };
}

Header Guards (SCREAMING_SNAKE_CASE):
--------------------------------------
#ifndef MY_AWESOME_PROJECT_EXAMPLE_H
#define MY_AWESOME_PROJECT_EXAMPLE_H
// ...
#endif

CMake Project (PascalCase):
----------------------------
project(MyAwesomeProject
    VERSION 1.0.0
    LANGUAGES CXX
)

vcpkg Package (kebab-case):
----------------------------
{
  "name": "my-awesome-project",  // Must be lowercase with hyphens
  "dependencies": [ ... ]
}


RENAME SCRIPT BEHAVIOR
======================

Input: my-awesome-project
-------------------------
Hyphenated: my-awesome-project (for vcpkg.json)
Lowercase:  my_awesome_project (for C++ namespaces)
Uppercase:  MY_AWESOME_PROJECT (for header guards)
CamelCase:  MyAwesomeProject (for CMake project name)

Input: MyAwesomeProject
-----------------------
Hyphenated: my-awesome-project (for vcpkg.json)
Lowercase:  my_awesome_project (for C++ namespaces)
Uppercase:  MY_AWESOME_PROJECT (for header guards)
CamelCase:  MyAwesomeProject (for CMake project name)

Input: my_awesome_project
-------------------------
Hyphenated: my-awesome-project (for vcpkg.json)
Lowercase:  my_awesome_project (for C++ namespaces)
Uppercase:  MY_AWESOME_PROJECT (for header guards)
CamelCase:  MyAwesomeProject (for CMake project name)


FILE LOCATIONS AFTER RENAME
============================

For project name "my-robot-controller":

vcpkg.json:
-----------
{
  "name": "my-robot-controller",  // kebab-case required by vcpkg
  ...
}

include/my_robot_controller/example.h:
---------------------------------------
#ifndef MY_ROBOT_CONTROLLER_EXAMPLE_H  // Header guard
#define MY_ROBOT_CONTROLLER_EXAMPLE_H

namespace my_robot_controller {  // Namespace
    class Example { };
}

#endif

CMakeLists.txt:
---------------
project(MyRobotController  # PascalCase
    VERSION 1.0.0
    LANGUAGES CXX
)

add_library(my_robot_controller_lib  # snake_case
    example.cpp
)


VALIDATION
==========

After running the rename script, verify:

✓ vcpkg.json has lowercase with hyphens
✓ C++ namespaces use underscores
✓ Header guards use UPPERCASE with underscores
✓ CMake project name is PascalCase
✓ Include directory matches namespace


TROUBLESHOOTING
===============

"vcpkg can't find my package":
-------------------------------
Check that vcpkg.json name uses hyphens:
- ✓ "name": "my-project"
- ✗ "name": "my_project"

"Namespace not found":
----------------------
Check that include directory matches namespace:
- include/my_project/
- namespace my_project { }

"CMake project name mismatch":
-------------------------------
CMake project names are case-sensitive and should be PascalCase:
- ✓ project(MyProject ...)
- ✗ project(my_project ...)


MANUAL FIXES
============

If the rename script produces incorrect names, you can manually fix:

1. vcpkg.json - Must be lowercase-with-hyphens
2. include/ directory - Should be lowercase_with_underscores
3. Namespace declarations - Should match include directory
4. Header guards - Should be UPPERCASE_WITH_UNDERSCORES
5. CMake project() - Should be PascalCase


REFERENCE
=========

Standard Conventions:
---------------------
- vcpkg packages: lowercase-kebab-case
- C++ namespaces: lower_snake_case
- Header guards: UPPER_SNAKE_CASE
- CMake projects: PascalCase
- File names: lower_snake_case.cpp

This template follows these conventions automatically when you use the
rename script with any input format.
