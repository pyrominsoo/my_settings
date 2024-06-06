cmake_minimum_required(VERSION 3.16)

project(
    practice
    VERSION 1.0
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Debug)
# set(CMAKE_BUILD_TYPE Release)

set(SYSTEMC_PATH /opt/systemc-2.3.4)
include_directories(${SYSTEMC_PATH}/include)

find_library(systemc systemc ${SYSTEMC_PATH}/lib-linux64)
link_directories(${SYSTEMC_PATH}/lib-linux64)



add_executable(
    prog
    src/main.cpp
)
target_link_libraries(prog systemc)
