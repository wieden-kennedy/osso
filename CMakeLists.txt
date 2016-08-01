cmake_minimum_required(VERSION 3.5.1)
PROJECT(bucky CXX)

#
# Make variables
#
SET(CMAKE_CXX_COMPILER /usr/bin/clang++)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "/usr/local/bin/")

#
# Ensure target compiler supports C++ 11 syntax
#
INCLUDE(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)

if(COMPILER_SUPPORTS_CXX11)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
        message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

#
# Alias main CPP files
#
SET(BUCKY_EL /opt/bucky/src/openmesh/src/calc_edge_lengths.cpp)
SET(BUCKY_VN /opt/bucky/src/openmesh/src/find_vertex_neighbors.cpp)

#
# Include lib and header directories
#
INCLUDE_DIRECTORIES(/usr/local/OpenMesh)
LINK_DIRECTORIES(/usr/lib)
LINK_DIRECTORIES(/usr/lib64)

#
# Set headers and create our executables
#
SET(HEADERS /usr/include/OpenMesh/Core/IO/MeshIO.hh /usr/include/OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh)

ADD_EXECUTABLE(bucky_el ${BUCKY_EL} ${HEADERS})
TARGET_LINK_LIBRARIES(bucky_el OpenMeshCore OpenMeshTools)

ADD_EXECUTABLE(bucky_vn ${BUCKY_VN} ${HEADERS})
TARGET_LINK_LIBRARIES(bucky_vn OpenMeshCore OpenMeshTools)
















