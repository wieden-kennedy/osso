//
//  main.cpp
//  find_neighbors
//
//  Created by Zhao He on 7/28/15.
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
    int vid = -1;
    PolyMesh mesh;
    
    if ( argc < 2 ) {
        cerr << "Usage:  find_neighbors <file>" << endl;
        cerr << "        find_neighbors <file> <vid>" << endl;
        return -1;
    }
    
    if ( ! OpenMesh::IO::read_mesh(mesh, argv[1]) ) {
        std::cerr << "Error: Cannot read mesh from " << argv[1] << std::endl;
        return -1;
    }
    
    if ( argc > 2) {
        int argv2 = atoi( argv[2] );
        if (argv2 > -1) vid = argv2;
    }
    
    cout << mesh.n_vertices() << endl << endl;
    
    for ( const auto& v: mesh.vertices() )
    {
        if ( v.idx() == vid || vid == -1 )
        {
            PolyMesh::Point p = mesh.point( v );
            printf( "v[%d]: %.2f %.2f %.2f\n", v.idx(), p[0], p[1], p[2] );
            for ( const auto& vv: mesh.vv_range(v) )
            {
                PolyMesh::Point n = mesh.point( vv );
                printf( "v[%d]: %.2f %.2f %.2f\n", vv.idx(), n[0], n[1], n[2]);
            }
            printf( "\n" );
        }
    }
    
    return 0;
}
