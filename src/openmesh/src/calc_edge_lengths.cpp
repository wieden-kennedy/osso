#include <cstdint>
#include <limits>
#include <iostream>
#include <fstream>
#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>
#include <rapidjson/document.h>

typedef OpenMesh::PolyMesh_ArrayKernelT<> PolyMesh;

using namespace std;
using namespace rapidjson;

int main(int argc, char *argv[])
{
    PolyMesh mesh;
    std::ifstream fin;
    Document document;
    stringstream buffer;

    if ( argc < 3 ) {
        cerr << "Usage:  calc_edge_lengths <mesh> <config.json>" << endl;
        return -1;
    }

    if ( ! OpenMesh::IO::read_mesh(mesh, argv[1]) ) {
        std::cerr << "Error: Cannot read mesh from " << argv[1] << std::endl;
        return -1;
    }

    if ( fin.open(argv[2]), !fin.good() ) {
        std::cerr << "Error: Cannot read file from " << argv[2] << std::endl;
        return -1;
    }

    cout << argv[1] << endl << endl;

    buffer << fin.rdbuf();
    string s = buffer.str();
    document.Parse(s.c_str());

    double dia_rod = document["dia_rod"].GetDouble();
    double dia_sphere =  document["dia_sphere"].GetDouble();
    double conn_len = document["conn_len"].GetDouble();
    double offset = sqrt(dia_sphere*dia_sphere/4.0 - dia_rod*dia_rod/4.0);

    int i = 0;
    double max_length = 0.0;
    double min_length = std::numeric_limits<std::int32_t>::max();
    double sum_length = 0.0;
    double avg_length = 0.0;

    for ( const auto& e: mesh.edges() ) {
        double length = mesh.calc_edge_length(e) - 2 * offset;
        cout << "e[" << i++ << "]: " << length << endl;
        max_length = std::max(max_length, length);
        min_length = std::min(min_length, length);
        sum_length += length;
    }

    avg_length = sum_length / i;

    cout << endl;
    cout << "Edge number         : " << mesh.n_edges() << endl;
    cout << "Edge length total   : " << sum_length << endl;
    cout << "Edge length average : " << avg_length << endl;
    cout << "Edge length max     : " << max_length << endl;
    cout << "Edge length min     : " << min_length << endl;

    if (min_length + 2 * offset < 2 * conn_len) {
        cout << endl << "WARNING: Some edge length is too short for the selected connector length " << conn_len << endl;
    }

    return 0;
}
