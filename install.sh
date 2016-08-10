#!/bin/bash

DARWIN="darwin"
DEBIAN="debian"
FEDORA="fedora"

OPENMESH_VER="6.2"
OPENMESH_URL="http://www.openmesh.org/media/Releases/${OPENMESH_VER}/OpenMesh-${OPENMESH_VER}.tar.gz"
OPENMESH_DL_DIR="/tmp/OpenMesh-${OPENMESH_VER=}"
n
RAPIDJSON_VER="1.0.2"
RAPIDJSON_URL="https://github.com/miloyip/rapidjson/archive/v${RAPIDJSON_VER}.tar.gz"
RAPIDJSON_DL_DIR="/tmp/rapidjson-${RAPIDJSON_VER}"

DEPS_TO_INSTALL=()
DARWIN_DEPS=("cmake" "git" "python" "pip" "wget")
DEBIAN_DEPS=("clang" "cmake" "git" "python" "pip" "wget")
FEDORA_DEPS=("cmake" "gcc" "gcc-c++" "git" "python" "pip" "wget")

# TEXT COLOR
NO_COLOR='\033[0m'
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'


function announce_install {
    echo -e "${YELLOW}"
    echo "#####################################"
    echo "# OpenVertex installing $@"
    echo "#####################################"
    echo -e "${NO_COLOR}"
}

function spinner {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

function package_install {

    case $1 in

        "build-essential" )
            announce_install "build-essential"
            sudo $INSTALLER install -y build-essential
            ;;

        "clang" )
            announce_install "clang"
            sudo $INSTALLER install -y clang
            ;;

        "cmake" )
            announce_install "cmake"
            sudo $INSTALLER install -y cmake
            ;;

        "gcc" )
            announce_install "gcc"
            sudo $INSTALLER install -y gcc
            ;;

        "gcc-c++" )
            announce_install "gcc-c++"
            sudo $INSTALLER install -y gcc-c++
            ;;

        "git" )
            announce_install "git"
            if [ $OS = $DARWIN ]; then
                $INSTALLER install git
            else
                sudo $INSTALLER install -y git
            fi
            ;;

        "python" )
            announce_install "python"
            if [ $OS = $DARWIN ]; then
                $INSTALLER install -y python
                $INSTALLER link python
            elif [ $OS = $DEBIAN ]; then
                sudo $INSTALLER install -y python2.7
                sudo ln -s /usr/bin/python2.7 /usr/bin/python
            elif [ $OS = $FEDORA ]; then
                sudo $INSTALLER install -y python
            fi
            ;;

        "pip" )
            announce_install "pip"
            if [ $OS != $DARWIN ]; then
                wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
                sudo `which python` get-pip.py
            fi
            ;;

        "wget" )
            announce_install "wget"
            sudo $INSTALLER install -y wget
            ;;
    esac
}


function deps {

    echo -e "${YELLOW}"
    echo "############################n#########"
    echo "Updating system packages"
    echo "#####################################"
    echo -e "${NO_COLOR}"

    (sudo $INSTALLER update -y) & spinner $!

    for dep in ${DEPS_TO_INSTALL[@]}; do
        package_install $dep
    done
}


function install_darwin {
    echo -e "${YELLOW}OS X detected."
    echo -e "${NO_COLOR}"

    if [ -z `which brew` ]; then
        echo -e "${RED}Homebrew is required to run this installer. "\
             "Please install Homebrew and re-run."
        exit 1
    fi

    preflight
    deps

    # install OpenSCAD
    announce_install "OpenSCAD"
    brew install openscad

    # install OpenMesh
    announce_install "OpenMesh"
    brew install open-mesh rapidjson

    # install SolidPython
    announce_install "SolidPython"
    sudo /usr/bin/pip install solidpython

    # link OpenSCAD binary to "openscad" for convenience
    ln -s /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD openscad

}


function install_debian {
    echo -e "${YELLOW}Debian-based system detected."
    echo -e "${NO_COLOR}"

    preflight
    deps

    # install OpenSCAD
    announce_install "OpenSCAD"
    sudo add-apt-repository -y ppa:openscad/releases
    sudo apt-get update -y
    sudo apt-get -y install openscad

    # install OpenMesh
    announce_install "OpenMesh"
    install_openmesh $OPENMESH_URL $OPENMESH_DL_DIR

    # install SolidPython
    announce_install "SolidPython"
    sudo apt-get install -y rapidjson-dev
    sudo `which pip` install solidpython

}


function install_fedora {
    echo -e "${YELLOW}Fedora-based system detected."
    echo -e "${NO_COLOR}"

    preflight
    deps

    # install OpenSCAD
    announce_install "OpenSCAD"
    sudo yum install -y openscad

    # install OpenMesh
    announce_install "OpenMesh"
    install_openmesh ${OPENMESH_URL} ${OPENMESH_DL_DIR}

    # install SolidPython
    announce_install "SolidPython"
    install_package ${RAPIDJSON_URL} ${RAPIDJSON_DL_DIR}
    sudo `which pip` install solidpython

}


function install_package () {
    URL=$1
    DL_DIR=$2
    wget ${URL} -O ${DL_DIR}.tar.gz
    tar xzf ${DL_DIR}.tar.gz
    mkdir -p ${DL_DIR}/build
    (cd ${DL_DIR}/build && cmake .. &&
            make &&
            sudo make install
    )

}

function install_openmesh () {
    wget ${OPENMESH_URL} -O ${OPENMESH_DL_DIR}.tar.gz
    tar xzf ${OPENMESH_DL_DIR}.tar.gz
    mkdir -p ${OPENMESH_DL_DIR}/build
    (cd ${OPENMESH_DL_DIR}/build && cmake .. \
                                          -DCMAKE_BUILD_TYPE=Release \
                                          -DC_MAKE_INSTALL_PREFIX=/usr \
                                          -DBUILD_APPS=OFF &&
            make &&
            sudo make install
    )

}

function preflight {
    echo -e "${YELLOW}"
    echo "################################################"
    echo "Checking for unmet system dependencies..."
    echo "################################################"
    echo -e "${NO_COLOR}"

    case $OS in
        $DEBIAN )
            _DEPS=${DEBIAN_DEPS[@]}
            INSTALLER=`which apt-get`
            ;;
        $DARWIN )
            _DEPS=${DARWIN_DEPS[@]}
            INSTALLER=`which brew`
            ;;
        $FEDORA )
            _DEPS=${FEDORA_DEPS[@]}
            INSTALLER=`which dnf`
    esac

    for key in $_DEPS; do

        if which $key > /dev/null; then
            echo -e "${CYAN}  -> found: $key"
        else
            DEPS_TO_INSTALL+=( $key )
        fi

    done

    function prompt_install {
        echo -e "${YELLOW}"
        echo "################################################"
        echo "OpenVertex requires these packages be installed:"
        echo "################################################"
        for key in ${DEPS_TO_INSTALL[@]}; do
           echo -e "    ${GREEN}- $key"
        done
        echo -e "${YELLOW}################################################"
        echo ""
        echo -e "${NO_COLOR}Continue? [Y/n]: "

        read response

        case $response in
            n )
                echo ""
                echo "Operation aborted."
                exit 0
                ;;
            N )
                echo ""
                echo "Operation aborted."
                exit 0
                ;;
            y )
                :
                ;;
            Y)
                :
                ;;
            "")
                :
                ;;
            *)
p                prompt_install
                ;;
        esac
    }

    prompt_install

}


function os_type {
    case `uname` in
        Linux )
            which dnf && { OS=$FEDORA; return; }
            which apt-get && { OS=$DEBIAN; return; }
            ;;
        Darwin )
            OS=$DARWIN
            ;;
    esac
}


function main {
    os_type


    case $OS in
        $DEBIAN )
            install_debian
            ;;
        $DARWIN )
            install_darwin
            ;;
        $FEDORA )
            install_fedora
            ;;
        * ) echo "Operating system not supported. Please use OS X, Debian/Ubuntu, " \
                 "or CentOS/Fedora/RHEL, or install required tools manually as " \
                 "outlined in the README file, at " \
                 "https://github.com/wieden#kennedy/open#vertex/master/README.md#manual#install."
    esac

    if [ -d /opt/open-vertex ]; then
        sudo rm -r /opt/open-vertex
    fi

    sudo git clone https://github.com/needybot/open-vertex /opt/open-vertex
    sudo ln -s /opt/open-vertex/scripts/run.sh /usr/local/bin/openvertex

    #Compile Shared Executables
    sudo clang++ \
         -std=c++11 \
         -I/usr/local/include \
         -L/usr/local/lib \
         -lOpenMeshCore \
         -lOpenMeshTools \
         /opt/open-vertex/openmesh/src/calc_edge_lengths.cpp -o /usr/local/bin/calc_edge_lengths

    sudo clang++ \
         -std=c++11 \
         -I/usr/local/include \
         -L/usr/local/lib \
         -lOpenMeshCore \
         -lOpenMeshTools \
         /opt/open-vertex/openmesh/src/find_vertex_neighbors.cpp -o /usr/local/bin/find_vertex_neighbors

}

main
