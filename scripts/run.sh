#/bin/bash

MESH_MODEL=$1

CONFIG_FILE="config.json"
ROOT_DIR="${HOME}/Documents/frank"
TMP_DIR=/tmp/`openssl rand -base64 8`
SCAD_DIR="generated/scad"
STL_DIR="generated/stl"
NEIGHBORS_FILE="neighbors.txt"
EDGE_LENGTHS_FILE="edge_lengths.txt"


function preflight {

    #############################################
    # Sets up temporary directory structure for #
    # generated files, and copies target model  #
    # into temporary root for work.             #
    #############################################

    if [ ! -d "${ROOT_DIR}" ]; then
        mkdir ${ROOT_DIR}
    fi

    # Create temporary directory structure
    mkdir ${TMP_DIR}
    mkdir -p ${TMP_DIR}/${SCAD_DIR}
    mkdir -p ${TMP_DIR}/${STL_DIR}

    # Copy the mesh model into the temp directory
    cp ${MESH_MODEL} ${TMP_DIR}/`basename ${MESH_MODEL}`
}


function frankify {

    ########################################################
    # Runs all processing on the target model and converts #
    # the mesh into a set of vertices and connectors for   #
    # output/printing.                                     #
    ########################################################

    # 1. Generate all neighbors of all vertices
    echo "[INFO] Finding vertex neighbors from $MESH_MODEL"
    /usr/local/bin/find_vertex_neighbors $MESH_MODEL > ${NEIGHBORS_FILE}
    echo "[INFO] Complete."
    echo ""

    echo "[INFO] Counting ${NUM_OF_VERTICES} in $NEIGHBORS_FILE"
    NUM_OF_VERTICES=`sed -n '1p' ${TMP_DIR}/${NEIGHBORS_FILE}`
    echo "[INFO] Complete."
    echo ""

    # 2. Calculate edge lengths
    echo "[INFO] Saved edge lengths to $EDGE_LENGTHS_FILE."
    /usr/local/bin/calc_edge_lengths $MESH_MODEL $CONFIG_FILE > ${EDGE_LENGTHS_FILE}
    echo "[INFO] Complete."
    echo ""

    # 3. Generate .scad
    echo "[INFO] Generating $NUM_OF_VERTICES pieces of connectors to $SCAD_DIR."
    python connector.py ${NEIGHBORS_FILE} ${SCAD_DIR}
    echo "[INFO] Complete."
    echo ""

    # 4. Generate .stl
    for i in $(eval echo "{0..$(($NUM_OF_VERTICES-1))}")
    do
        echo "[INFO] Generating $STL_DIR/conn$i.stl..."
        openscad -o $STL_DIR/conn$i.stl $SCAD_DIR/conn$i.scad
    done
}


function main {

    ####################
    # Entry point      #
    ####################

    preflight

    (cd ${TMP_DIR} && frankify)
    mv ${TMP_DIR} ${ROOT_DIR}/`date +"%Y-%m-%d"`
}


main

