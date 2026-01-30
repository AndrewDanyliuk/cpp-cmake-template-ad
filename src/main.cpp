#include "PROJECT_NAME_LOWER/example.h"
#include <iostream>

/** MUST HAVE THIS ADDED AS AN EXECUTABLE IN src/CMakeLists.txt FOR IT TO BE PART OF COMPILATION. **/
int main()
{
    PROJECT_NAME_LOWER::Example example(42);
    std::cout << "Value: " << example.getValue() << std::endl;
    return 0;
}
