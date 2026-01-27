#include "PROJECT_NAME_LOWER/example.h"

namespace PROJECT_NAME_LOWER {

Example::Example(int value) : value_(value) {}

int Example::getValue() const
{
    return value_;
}

void Example::setValue(int value)
{
    value_ = value;
}

int Example::add(int amount)
{
    value_ += amount;
    return value_;
}

}  // namespace PROJECT_NAME_LOWER
