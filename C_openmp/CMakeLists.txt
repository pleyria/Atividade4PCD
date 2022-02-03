cmake_minimum_required(VERSION 3.16)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS_RELEASE "-O3")

project(igraph_rumor)

find_package(igraph REQUIRED)

add_executable(igraph_rumor igraph_rumor.c)
target_link_libraries(igraph_rumor PUBLIC igraph::igraph)