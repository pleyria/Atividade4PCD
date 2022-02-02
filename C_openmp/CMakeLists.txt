cmake_minimum_required(VERSION 3.16)
project(rumor)

find_package(igraph REQUIRED)

add_executable(rumor_exec rumor.c)
target_link_libraries(igraph_test PUBLIC igraph::igraph)


