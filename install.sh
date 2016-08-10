#!/bin/bash

DARWIN="darwin"
DEBIAN="debian"
FEDORA="fedora"

OPENMESH_VER="6.2"
OPENMESH_URL="http://www.openmesh.org/media/Releases/${OPENMESH_VER}/OpenMesh-${OPENMESH_VER}.tar.gz"
OPENMESH_DL_DIR="/tmp/OpenMesh-${OPENMESH_VER=}"

RAPIDJSON_VER="1.0.2"
RAPIDJSON_URL="https://github.com/miloyip/rapidjson/archive/v${RAPIDJSON_VER}.tar.gz"
RAPIDJSON_DL_DIR="/tmp/rapidjson-${RAPIDJSON_VER}"

DEPS_TO_INSTALL=()
DARWIN_DEPS=("cmake" "git" "python" "pip" "wget")
DEBIAN_DEPS=("clang" "cmake" "git" "python" "pip" "wget")
FEDORA_DEPS=("clang" "cmake" "gcc" "gcc-c++" "git" "python" "pip" "wget")

# TEXT COLOR
NO_COLOR="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

REINSTALL=0
USAGE=0


function announce_install {
    echo -e "${YELLOW}"
    echo "#####################################"
    echo -e "# ${WHITE}OpenVertex installing $@"
    echo -e "${YELLOW}#####################################"
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
    echo -e "${WHITE}Updating system packages"
    echo -e "${YELLOW}#####################################"
    echo -e "${NO_COLOR}"

    (sudo $INSTALLER update -y) & spinner $!

    for dep in ${DEPS_TO_INSTALL[@]}; do
        package_install $dep
    done
}


function install_darwin {
    echo -e "${YELLOW}I LOVE OS X. COOL TO THE MAX!!"
    echo -e "${NO_COLOR}"

    if [ -z `which brew` ]; then
        echo -e "${RED}Sorry, but I need Homebrew to finish up. "\
             "Can you please install Homebrew and fire me back up?"
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
    echo -e "${YELLOW}Oooh snap! Skubuntu is my favorite! We are so much alike."
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
    install_package $OPENMESH_URL $OPENMESH_DL_DIR \
                    -DCMAKE_BUILD_TYPE=Release \
                    -DC_MAKE_INSTALL_PREFIX=/usr \
                    -DBUILD_APPS=OFF

    # install SolidPython
    announce_install "SolidPython"
    sudo apt-get install -y rapidjson-dev
    sudo `which pip` install solidpython

}


function install_fedora {
    echo -e "${YELLOW}DNF with Fedora is all I'm really sayin' though."
    echo -e "${NO_COLOR}"

    preflight
    deps

    # install OpenSCAD
    announce_install "OpenSCAD"
    sudo yum install -y openscad

    # install OpenMesh
    announce_install "OpenMesh"
    install_package ${OPENMESH_URL} ${OPENMESH_DL_DIR} \
                    -DCMAKE_BUILD_TYPE=Release \
                    -DC_MAKE_INSTALL_PREFIX=/usr \
                    -DBUILD_APPS=OFF


    # install SolidPython
    announce_install "SolidPython"
    install_package ${RAPIDJSON_URL} ${RAPIDJSON_DL_DIR}
    sudo `which pip` install solidpython

}


function install_package {
    URL=$1
    DL_DIR=$2
    CMAKE_ARGS=${@:3}
    wget ${URL} -O ${DL_DIR}.tar.gz
    tar xzf ${DL_DIR}.tar.gz
    mkdir -p ${DL_DIR}/build

    (cd ${DL_DIR}/build && cmake .. ${CMAKE_ARGS} &&
            make &&
            sudo make install
    )

}


function preflight {
    echo -e "${YELLOW}"
    echo "################################################"
    echo -e "${WHITE}Checking for missing dependencies..."
    echo -e "${YELLOW}################################################"
    echo -e "${NO_COLOR}"
    sleep 1

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
        echo -e "${WHITE}I'm gonna need to install some stuff::"
        echo -e "${YELLOW}################################################"
        for key in ${DEPS_TO_INSTALL[@]}; do
           echo -e "    ${GREEN}- $key"
        done
        echo -e "${YELLOW}################################################"
        echo ""
        echo -e "${NO_COLOR}That alright? [${GREEN}Y${NO_COLOR}/${RED}n${NO_COLOR}]: "

        read -s response

        case $response in
            no|No|NO|n|N|0 )
                echo ""
                echo ":( Dangit. Ok, see you some other time, maybe."
                exit 0
                ;;
            yes|Yes|YES|y|Y|1|"" )
                :
                ;;
            *)
                prompt_install
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


function usage {
    echo -e "${CYAN}USAGE: ${WHITE}openvertex [PATH_TO_MODEL]"
    echo ""

    exit 0
}


function check_already_installed {
    if [[ `command -v openvertex` && REINSTALL -eq 0 ]]; then
        echo ""
        echo -e "${WHITE}Looks like OpenVertex has already been installed on this machine."
        echo "To reinstall, run this installer again using the --force flag."

        exit 1
    fi
}


function welcome {
    echo ""
    echo -e "${YELLOW}################################################################################"
    echo ""
    echo "                 BBBB      UU   UU     CC     KK   KK   YY   YY"
    echo "                 BB  B     UU   UU   CC  CC   KK  KK     YY YY"
    echo "                 BB  B     UU   UU   CC       KK KK       YY"
    echo "                 BB  B     UU   UU   CC       KKKK        YY"
    echo "                 BBBB      UUU UUU   CC       KKKK        YY"
    echo "                 BB  B      UUUUU    CC  CC   KK KK       YY"
    echo "                 BB  B                 CC     KK  KK      YY"
    echo "                 BB  B                        KK   KK"
    echo "                 BBBB"
    echo -e "${RED}                                __________"
    echo "                              .~#########%%;~."
    echo "                             /############%%;.\\"
    echo "                            /######/~\/~\%%;,;,\\"
    echo "                           |#######\    /;;;;.,.|"
    echo "                           |#########\/%;;;;;.,.|"
    echo "                  XX       |##/~~\####%;;;/~~\;,|       XX"
    echo "                XX..X      |#|  o  \##%;/  O  |.|      X..XX"
    echo "              XX.....X     |##\____/##%;\____/.,|     X.....XX"
    echo "         XXXXX.....XX      \#########/\;;;;;;,, /      XX.....XXXXX"
    echo "        X |......XX%,.@      \######/  \;;;;, /      @#%,XX......| X"
    echo "        X |.....X  @#%,.@     |######%%;;;;,.|     @#%,.@  X.....| X"
    echo "        X  \...X     @#%,.@   |# # # % ; ; ;,|   @#%,.@     X.../  X"
    echo "         X# \.X        @#%,.@                  @#%,.@        X./  #"
    echo "          ##  X          @#%,.@              @#%,.@          X   #"
    echo "        , \"# #X            @#%,.@          @#%,.@            X ##"
    echo "           \`###X             @#%,.@      @#%,.@             ####'"
    echo "          . \' ###              @#%.,@  @#%,.@              ###"
    echo "            . \";\"                @#%.@#%,.@                ;\"\` \' "
    echo "              \'                    @#%,.@                   ,."
    echo "              \` ,                @#%,.@  @@                \`"
    echo ""
    echo ""
    echo -e "${YELLOW}################################################################################"
    echo -e "${WHITE}  Thanks for choosing BUCKY for your 3D-printing endeavors! I hope you enjoy!"
    echo -e "     To get started, I may need to install a few things. Sound ok? [${GREEN}Y${WHITE}/${RED}n${WHITE}]"
    echo -e "${YELLOW}################################################################################"
    echo -e "${NO_COLOR}"

    function get_response {
        read -s response

        case $response in
            yes|Yes|YES|y|Y|1|"" )
                echo -e "${RED}"
                echo "           AA    WW    WW  EEEEE    SS      OO    MM    MM  EEEEE  !!!"
                echo "          A  A   WW    WW  EE     SS  SS  OO  OO  MMM  MMM  EE     !!!"
                echo "         AAAAAA  WW WW WW  EEEE   SS      OO  OO  MM MM MM  EEEE   !!!"
                echo "        A      A WWW  WWW  EE      SS     OO  OO  MM    MM  EE     !!!"
                echo "        A      A WW    WW  EEEEE    SS      OO    MM    MM  EE     !!!"
                echo "                 WW    WW            SS                     EE"
                echo "                                 SS  SS                     EEEEE  !!!"
                echo "                                 SS SS                             !!!"
                echo "                                   SS"
                echo ""
                sleep 1
                echo -e "${RED}              First I need to check out your system and stuff..."
                echo ""
                echo ""
                echo -e "${YELLOW}################################################################################"
                echo ""
                sleep 2
                return
                ;;
            no|No|NO|n|N|0 )
                echo "Gotcha. See you later, pal. Let the record show that the operation has been canceled."
                exit 1
                ;;
            * )
                echo "Sorry, there buddy. I am a program, and only speak binary. Please answer yes or no."
                echo ""
                get_response
                ;;
        esac
    }

    get_response
}


function main {

    if [ $USAGE -eq 1 ]; then
        usage
    fi

    clear
    check_already_installed
    welcome
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
                 "https://github.com/wieden#kennedy/open-vertex/master/README.md#manual-install."
    esac

    # Grab Bucky Source
    if [ -d /opt/open-vertex ]; then
        (cd /opt/open-vertex && sudo git pull origin master)
    else
        sudo git clone https://github.com/needybot/open-vertex /opt/open-vertex
    fi

    if [ ! -L /usr/local/bin/openvertex ]; then
        sudo ln -s /opt/open-vertex/scripts/run.sh /usr/local/bin/openvertex
    fi

    if [ ! -L /usr/local/bin/connector ]; then
        sudo ln -s /opt/open-vertex/scripts/connector.py /usr/local/bin/connector
    fi

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

for arg in $@; do
    if [[ ${arg} = '-h' || ${arg} = "--help" ]]; then
        USAGE=1
    elif [[ ${arg} = "-f" || ${arg} = "--force" ]]; then
        REINSTALL=1
    fi
done

main
