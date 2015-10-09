#/bin/sh

MESH_MODEL=$1

SCAD_DIR="./scad"
STL_DIR="./stl"
NEIGHBORS_FILE="neighbors.txt"
EDGE_LENGTHS_FILE="edge_lengths.txt"

# 1. Generate all neighbors of all vertices
echo "[INFO] Found neighbors from $MESH_MODEL"
./find_vertex_neighbors $MESH_MODEL > $NEIGHBORS_FILE

echo "[INFO] Saved neighbors to $NEIGHBORS_FILE"
NUM_OF_VERTICES=`sed -n '1p' neighbors.txt`

# 2. Calculate edge lengths
echo "[INFO] Calculated edge lengths"
echo "[INFO] Saved edge lengths to $EDGE_LENGTHS_FILE"
./calc_edge_lengths $MESH_MODEL > $EDGE_LENGTHS_FILE

# 3. Generate .scad
python connector.py $NEIGHBORS_FILE $SCAD_DIR
echo "[INFO] Generated $NUM_OF_VERTICES pieces of connectors to $SCAD_DIR"

# 4. Generate .stl
if [ ! -d "$STL_DIR" ]; then
    mkdir $STL_DIR
fi

for i in $(eval echo "{0..$(($NUM_OF_VERTICES-1))}")
do
    echo "[INFO] Generating $STL_DIR/conn$i.stl..."
    openscad -o $STL_DIR/conn$i.stl $SCAD_DIR/conn$i.scad
done
