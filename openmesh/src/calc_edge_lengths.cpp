//
//  main.cpp
//  calc_edge_lengths
//
//  Created by Zhao He on 8/4/15.
//  Copyright (c) 2015 Wieden+Kennedy. All rights reserved.
//

//
// $ brew install open-mesh
//

#include <iostream>
#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>

typedef OpenMesh::PolyMesh_ArrayKernelT<> PolyMesh;

using namespace std;

int main(int argc, char *argv[])
{
    PolyMesh mesh;
    
    if ( argc < 2 ) {
        cerr << "Usage:  calc_edge_lengths <file>" << endl;
        return -1;
    }
    
    if ( ! OpenMesh::IO::read_mesh(mesh, argv[1]) ) {
        std::cerr << "Error: Cannot read mesh from " << argv[1] << std::endl;
        return -1;
    }
    
    cout << argv[1] << endl << endl;

    int i = 0;
    float max_length = 0.0;
    float min_length = INT_MAX;
    float sum_length = 0.0;
    float avg_length = 0.0;
    
    for ( const auto& e: mesh.edges() ) {
        float length = mesh.calc_edge_length(e);
        cout << "e[" << i++ << "]: " << length << endl;
        max_length = std::max(max_length, length);
        min_length = std::min(min_length, length);
        sum_length += length;
    }
    
    avg_length = sum_length / i;
    
    cout << endl;
    cout << "Edge  total  length: " << sum_length << endl;
    cout << "Edge average length: " << avg_length << endl;
    cout << "Edge   max   length: " << max_length << endl;
    cout << "Edge   min   length: " << min_length << endl;
    
    return 0;
}
