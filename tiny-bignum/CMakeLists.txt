cmake_minimum_required (VERSION 3.10)
project (TinyBignum CXX C)

include(FetchContent)

FetchContent_Declare(
  GoogleBenchmark
  URL https://github.com/google/benchmark/archive/v1.4.1.tar.gz
  )

if (NOT GoogleBenchmark_POPULATED)
  FetchContent_Populate(GoogleBenchmark)
  set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "From Gtest")
  set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "From Gtest")
  add_subdirectory(${googlebenchmark_SOURCE_DIR} ${googlebenchmark_BINARY_DIR})
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR} )

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -W -Wall -O2")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")


add_library(tiny_bignum)
target_compile_features(tiny_bignum PUBLIC cxx_std_17)
target_include_directories(tiny_bignum PRIVATE ".")
target_sources(tiny_bignum PRIVATE
    bn.c
    tests/miller.c
)


add_executable(miller
    tests/miller_test.c
)
target_include_directories(miller PRIVATE ".")
target_compile_features(miller PUBLIC cxx_std_17)
target_link_libraries(miller PRIVATE tiny_bignum)

add_executable(bench
    bench/benchmark.cpp
)
target_include_directories(bench PRIVATE ".")
target_compile_features(bench PUBLIC cxx_std_17)
target_link_libraries(bench PRIVATE benchmark tiny_bignum)
