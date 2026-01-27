#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>
#include <gmock/gmock.h>

#include "PROJECT_NAME_LOWER/example.h"

using namespace PROJECT_NAME_LOWER;
using ::testing::Return;
using ::testing::_;

// =============================================================================
// Basic Catch2 Tests
// =============================================================================

TEST_CASE("Example constructor sets initial value", "[example]")
{
    Example ex(42);
    REQUIRE(ex.getValue() == 42);
}

TEST_CASE("Example setValue changes value", "[example]")
{
    Example ex(10);
    ex.setValue(20);
    REQUIRE(ex.getValue() == 20);
}

TEST_CASE("Example add increases value", "[example]")
{
    Example ex(5);
    int result = ex.add(3);
    REQUIRE(result == 8);
    REQUIRE(ex.getValue() == 8);
}

TEST_CASE("Example handles negative numbers", "[example]")
{
    Example ex(10);
    ex.add(-5);
    REQUIRE(ex.getValue() == 5);
}

// =============================================================================
// Catch2 SECTION-based Tests
// =============================================================================

TEST_CASE("Example with sections", "[example]")
{
    Example ex(0);

    SECTION("Adding positive numbers")
    {
        ex.add(5);
        ex.add(3);
        REQUIRE(ex.getValue() == 8);
    }

    SECTION("Setting value directly")
    {
        ex.setValue(100);
        REQUIRE(ex.getValue() == 100);
    }

    SECTION("Multiple operations")
    {
        ex.setValue(10);
        ex.add(5);
        ex.add(-3);
        REQUIRE(ex.getValue() == 12);
    }
}

// =============================================================================
// Catch2 BDD-style Tests (SCENARIO/GIVEN/WHEN/THEN)
// =============================================================================

SCENARIO("Example can be used as a counter", "[example]")
{
    GIVEN("An example with initial value")
    {
        Example ex(0);

        WHEN("We add positive numbers")
        {
            ex.add(5);
            ex.add(3);

            THEN("The value should be correct")
            {
                REQUIRE(ex.getValue() == 8);
            }
        }

        WHEN("We set a new value")
        {
            ex.setValue(100);

            THEN("The value should be updated")
            {
                REQUIRE(ex.getValue() == 100);
            }
        }
    }
}

// =============================================================================
// Google Mock Examples
// =============================================================================

// Interface for demonstration
class ICalculator
{
public:
    virtual ~ICalculator() = default;
    virtual int calculate(int a, int b) = 0;
    virtual double divide(double a, double b) = 0;
};

// Mock implementation
class MockCalculator : public ICalculator
{
public:
    MOCK_METHOD(int, calculate, (int a, int b), (override));
    MOCK_METHOD(double, divide, (double a, double b), (override));
};

TEST_CASE("Mock calculator basic usage", "[mock]")
{
    MockCalculator mock;

    // Set expectation
    EXPECT_CALL(mock, calculate(2, 3))
        .WillOnce(Return(5));

    // Use mock
    int result = mock.calculate(2, 3);
    REQUIRE(result == 5);
}

TEST_CASE("Mock calculator with multiple calls", "[mock]")
{
    MockCalculator mock;

    // Expect multiple calls
    EXPECT_CALL(mock, calculate(_, _))
        .Times(3)
        .WillOnce(Return(10))
        .WillOnce(Return(20))
        .WillOnce(Return(30));

    REQUIRE(mock.calculate(1, 2) == 10);
    REQUIRE(mock.calculate(3, 4) == 20);
    REQUIRE(mock.calculate(5, 6) == 30);
}

TEST_CASE("Mock calculator with matchers", "[mock]")
{
    using ::testing::Gt;
    using ::testing::Le;

    MockCalculator mock;

    // Use matchers for flexible expectations
    EXPECT_CALL(mock, calculate(Gt(0), Le(10)))
        .WillRepeatedly(Return(100));

    REQUIRE(mock.calculate(5, 8) == 100);
    REQUIRE(mock.calculate(1, 10) == 100);
}

TEST_CASE("Mock calculator with actions", "[mock]")
{
    using ::testing::Invoke;

    MockCalculator mock;

    // Use custom action
    EXPECT_CALL(mock, divide(_, _))
        .WillOnce(Invoke([](double a, double b) -> double {
            if (b == 0.0) {
                return 0.0;  // Handle division by zero
            }
            return a / b;
        }));

    double result = mock.divide(10.0, 2.0);
    REQUIRE_THAT(result, Catch::Matchers::WithinAbs(5.0, 0.001));
}

// =============================================================================
// Combining Catch2 and Google Mock
// =============================================================================

// Class that depends on calculator
class ComputationEngine
{
public:
    explicit ComputationEngine(ICalculator& calc) : calc_(calc) {}

    int performOperation(int a, int b)
    {
        return calc_.calculate(a, b);
    }

private:
    ICalculator& calc_;
};

TEST_CASE("ComputationEngine with mocked dependency", "[mock][integration]")
{
    MockCalculator mock_calc;
    ComputationEngine engine(mock_calc);

    SECTION("Successful calculation")
    {
        EXPECT_CALL(mock_calc, calculate(5, 3))
            .WillOnce(Return(8));

        int result = engine.performOperation(5, 3);
        REQUIRE(result == 8);
    }

    SECTION("Multiple calculations")
    {
        EXPECT_CALL(mock_calc, calculate(_, _))
            .Times(2)
            .WillRepeatedly(Return(42));

        REQUIRE(engine.performOperation(1, 2) == 42);
        REQUIRE(engine.performOperation(3, 4) == 42);
    }
}

// =============================================================================
// Example of Test Fixture with Mock
// =============================================================================

class CalculatorTestFixture
{
protected:
    MockCalculator mock_calc;
    std::unique_ptr<ComputationEngine> engine;

    void SetUp()
    {
        engine = std::make_unique<ComputationEngine>(mock_calc);
    }
};

TEST_CASE_METHOD(CalculatorTestFixture, "Test with fixture", "[mock][fixture]")
{
    SetUp();

    EXPECT_CALL(mock_calc, calculate(10, 20))
        .WillOnce(Return(30));

    REQUIRE(engine->performOperation(10, 20) == 30);
}
