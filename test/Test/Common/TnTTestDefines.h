#pragma once

#include <cstdint>
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#define ASSERT_NULL(ptr)     ASSERT_TRUE(ptr == nullptr) << #ptr " was not a nullptr when nullptr was expected! "
#define ASSERT_NOT_NULL(ptr) ASSERT_TRUE(ptr != nullptr) << #ptr " was a nullptr when nullptr was not expected! "

#ifdef TNT_NO_EXCEPTIONS
#   define ASSERT_DEATH_OR_THROW(statement, exception) ASSERT_DEATH(statement, ".*")
#else
#   define ASSERT_DEATH_OR_THROW(statement, exception) ASSERT_THROW(statement, exception)
#endif

