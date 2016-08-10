#/bin/bash

# GLOBAL
USAGE=0
MESH_MODEL=""

# CONSTANTS
CONFIG_FILE="config.json"
ROOT_DIR="${HOME}/Documents/steveapp"
TMP_DIR=/tmp/$(openssl rand -base64 8)
SCAD_DIR="generated/scad"
STL_DIR="generated/stl"
NEIGHBORS_FILE="neighbors.txt"
EDGE_LENGTHS_FILE="edge_lengths.txt"

# TEXT COLOR
NO_COLOR="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

PROMPTS=("GOOD NEWS" "RADNESS" "OH YEAH" "BODACIOUS" "OUTTA SIGHT" "UNREAL" "ACHIEVEMENT UNLOCKED")


function preflight {

    # Sets up temporary directory structure for
    # generated files, and copies target model
    # into temporary root for work.

    if [ ! -d "${ROOT_DIR}" ]; then
        mkdir ${ROOT_DIR}
    fi

    # Create temporary directory structure
    mkdir ${TMP_DIR}
    mkdir -p ${TMP_DIR}/${SCAD_DIR}
    mkdir -p ${TMP_DIR}/${STL_DIR}

    # Copy the mesh model into the temp directory
    cp ${MESH_MODEL} ${TMP_DIR}/$(basename ${MESH_MODEL})
}


function random_prompt {

    # Gets a random prompt for information output

    random=$$$(date +%s)
    echo ${PROMPTS[$random % ${#PROMPTS[@]}]}
}


function report {

    # Reports execution status with info prompt

    report_type="INFO"
    if [ ! -z $2 ]; then
        report_type=$2
    fi

    echo -e "${YELLOW}[${report_type}] ${NO_COLOR}$1"
}

function bucky {

    # Runs all processing on the target model and converts
    # the mesh into a set of vertices and connectors for
    # output/printing.

    # 1. Generate all neighbors of all vertices
    report "Finding vertex neighbors from $MESH_MODEL"
    /usr/local/bin/find_vertex_neighbors $MESH_MODEL > ${NEIGHBORS_FILE}
    report "Complete." $(random_prompt)
    echo ""

    report "Counting ${NUM_OF_VERTICES} in $NEIGHBORS_FILE"
    NUM_OF_VERTICES=$(sed -n '1p' ${TMP_DIR}/${NEIGHBORS_FILE})
    report "I did something right!." $(random_prompt)
    echo ""

    # 2. Calculate edge lengths
    report "Saved edge lengths to $EDGE_LENGTHS_FILE."
    /usr/local/bin/calc_edge_lengths $MESH_MODEL $CONFIG_FILE > ${EDGE_LENGTHS_FILE}
    report "That worked!" $(random_prompt)
    echo ""

    # 3. Generate .scad
    report "Generating $NUM_OF_VERTICES pieces of connectors to $SCAD_DIR."
    python connector.py ${NEIGHBORS_FILE} ${SCAD_DIR}
    report "I Did it." "SCAD-TASTIC"
    echo ""

    # 4. Generate .stl
    for i in $(eval echo "{0..$(($NUM_OF_VERTICES-1))}")
    do
        report "Generating $STL_DIR/conn$i.stl..."
        openscad -o $STL_DIR/conn$i.stl $SCAD_DIR/conn$i.scad
        report "I generated that STL for ya." $(random_prompt)
    done
}


function usage {

    ####################
    # HALP ME PLEZE    #
    ####################

    echo ""
    echo -e "${CYAN}USAGE: ${WHITE}steveit [PATH_TO_MESH_MODEL]"
    exit 0
}


function main {

    # Entry point

    for arg in $@; do
        if [[ ${arg} = '-h' || ${arg} = "--help" ]]; then
            USAGE=1
        elif [ -f ${arg} ]; then
            MESH_MODEL=${arg}
        fi
    done

    preflight

    (cd ${TMP_DIR} && bucky)

    date_stamp=$(date +"%s")

    mv ${TMP_DIR} ${ROOT_DIR}/generated-${date_stamp}
    report "So, hey...I got all that taken care of for you. You can find the generated" \
           "files right up in here: ${ROOT_DIR}/generated-${date_stamp}" $(random_prompt)
}


# Dude, jam it!
main $@

