cmake_minimum_required(VERSION 3.16)
project(igraph_rumor)

find_package(igraph REQUIRED)

add_executable(igraph_rumor igraph_rumor.c)
target_link_libraries(igraph_rumor PUBLIC igraph::igraph)