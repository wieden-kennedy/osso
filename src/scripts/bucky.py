#!/usr/bin/env python

import argparse
import datetime
import os
import random
import shutil
import sys
<<<<<<< HEAD

from sh import bucky_el, bucky_vn, connector, openscad, sudo

BUILD_PATH = '/opt/bucky/build'
CONFIG_FILE = '/opt/bucky/config.json'
=======
import time

from sh import bucky_el, bucky_vn, connector, openscad, sudo

BUCKY_PATH = '/opt/bucky'
BUILD_PATH = os.path.join(BUCKY_PATH, 'build')
CONFIG_FILE = os.path.join(BUCKY_PATH,'config.json')
>>>>>>> develop
ROOT_DIR = os.path.expanduser('~/Documents/__bucky__')

TMP_DIR = '/tmp/{}'.format(str(random.getrandbits(64)))
SCAD_DIR = os.path.join(TMP_DIR, 'scad')
STL_DIR = os.path.join(TMP_DIR, 'stl')

NEIGHBORS_FILE = os.path.join(TMP_DIR, 'neighbors.txt')
EDGE_LENGTHS_FILE = os.path.join(TMP_DIR, 'edge_lengths.txt')

PYTHON_MAJOR_VERS = sys.version_info[0]

PROMPTS = [
    'ACHIEVEMENT UNLOCKED',
    'BALLER',
    'BODACIOUS',
    'BOOM',
    'FANTASTIC',
    'GOOD NEWS',
    'OH, YEAH',
    'OUTTA SIGHT',
    'RADNESS',
    'SIIIIIICK',
    'UNREAL',
    'WHOOP WHOOP',
]

# TEXT COLOR
NO_COLOR = '\033[0m'
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[0;33m'


def bucky(mesh_model):

    """
    Runs all processing on the target model and converts the mesh into a set
    of vertices and connectors for output/printing.

    Args:
        mesh_model (str): the path to the mesh model to convert
    """

    #Generate all neighbors of all vertices
    report('Finding vertex neighbors from {}'.format(mesh_model))
    try:
        bucky_vn(mesh_model, _out=NEIGHBORS_FILE)
        report('Complete.', report_type=random.choice(PROMPTS))
    except Exception as e:
        report_err(e)
        sys.exit(1)


    report('Counting vertices in {}'.format(NEIGHBORS_FILE))
    try:
        with open(NEIGHBORS_FILE, 'r') as nf:
            num_vertices = int(nf.readlines()[0].strip())
        report('I did something right!', report_type=random.choice(PROMPTS))
    except Exception as e:
        report_err(e)
        sys.exit(1)


    #Calculate edge lengths
    report('Saving edge lengths to {}.'.format(EDGE_LENGTHS_FILE))
    try:
        edge_lengths_data = bucky_el(mesh_model, CONFIG_FILE,
                                     _out=EDGE_LENGTHS_FILE)
        report('Well, that worked!', report_type=random.choice(PROMPTS))
    except Exception as e:
        report_err(e)
        sys.exit(1)


    #Generate .scad
    report('Generating {} connectors to {}.'.format(num_vertices, SCAD_DIR))
    try:
        connector('-n', NEIGHBORS_FILE, '-o', SCAD_DIR)
        report('I did it!', report_type='SCAD-TASTIC')
    except Exception as e:
        report_err(e)
        sys.exit(1)


    #Generate .stl
    for i in range(0, num_vertices):
        remaining = num_vertices - (i + 1)
        report('Generating connector {}...{} remaining.'.format(i + 1, remaining))
        try:
            openscad('-o',
                     os.path.join(STL_DIR, 'conn{}.stl'.format(i)),
                     os.path.join(SCAD_DIR, 'conn/{}.scad'.format(i)))
            report('I generated that STL for ya.',
                   report_type=random.choice(PROMPTS))
        except Exception as e:
            report_err(e)
            sys.exit(1)


def compile_binaries():

    """
    Recompiles Bucky's binary files using cmake.
    """

    if not os.path.exists(BUILD_PATH):
        report('Creating build path', )
        sudo.mkdir('-p', BUILD_PATH)
    else:
        report('Removing old build information')
        sudo.rm('-rf', BUILD_PATH)
        sudo.mkdir('-p', BUILD_PATH)

    os.chdir(BUILD_PATH)
    report('Compiling Bucky binary files')
    sudo.cmake('..')
    sudo.make()


def parse_args():

    """
    Argument parser for this program.

    Returns:
        args (argparse.Namespace): kv tuple of arguments and their values
    """

    parser = argparse.ArgumentParser()

    parser.add_argument('-c', '--compile-binaries', dest='compile_binaries',
                        action='store_true', help='used to recompile Bucky\'s binaries')
    parser.add_argument('-m', '--model', type=str, dest='model_path',
                        help='absolute path to the .obj model file')
    parser.add_argument('-r', '--remove', action="store_true", dest='remove',
                        help='used to completely remove bucky from your system')
    parser.add_argument('-u', '--update', action="store_true",
                        dest='update', help='used to update the bucky codebase')

    if len(sys.argv[1:]) == 0:
        parser.print_help()
        parser.exit()

    return parser.parse_args()


def preflight(model_file):

    """
    Ensures all required directories exist and copies model file to
    temp output location.
    """

    if not os.path.exists(ROOT_DIR):
        os.makedirs(ROOT_DIR)

    for d in [TMP_DIR, SCAD_DIR, STL_DIR]:
        os.makedirs(d)

    file_name = os.path.basename(model_file)
    shutil.copyfile(model_file, os.path.join(TMP_DIR, file_name))

    return os.path.join(TMP_DIR, model_file)


def remove_bucky():

    if PYTHON_MAJOR_VERS == 2:
        prompt_func = raw_input
    else:
        prompt_func = input

    input_string = '''
    ################################################################################
    \m/~\m/~\m/~\m/~\m/~\m/~\m/~ DECIDE BUCKY'S FATE!!! ~\m/~\m/~\m/~\m/~\m/~\m/~\m/
    ################################################################################

    Ok, actually, there's only one choice. Please type 'die bucky die' to confirm.\n
    '''

    if prompt_func(input_string) == 'die bucky die':
        print('\n\n')
        report('Reluctantly removing Bucky components from your system.', report_type="SAD PANTS")
        time.sleep(1)
        sudo.rm('-rf', BUCKY_PATH)
        sudo.rm('-f', '/usr/local/bin/bucky')
        sudo.rm('-f', '/usr/local/bin/bucky_el')
        sudo.rm('-f', 'usr/local/bin/bucky_vn')
        sudo.rm('-f', '/usr/local/bin/connector')

        print('\n--------------------------------------------------------------------------------')
        print('{}------------------------------- GREAT NEWS!!! ----------------------------------'.format(GREEN))
        print('{}--------------------------------------------------------------------------------\n'.format(NO_COLOR))
        report('SUCCESS! You are now Bucky-free...happy Friday! \n\tIt\'s Friday somewhere, right? \n\t\tWe can\'t really tell without Bucky in our world :(',
               report_type='NOT_SUCCESS')
    else:
        print('--------------------------------------------------------------------------------')
        print('{}------------------------------- GREAT NEWS!!! ----------------------------------'.format(GREEN))
        print('{}--------------------------------------------------------------------------------\n'.format(NO_COLOR))
        report('SUCCESS! You decided to not kill Bucky! \n\tWe REJOICE in your benevolent heart!!', report_type='SO OVERJOYED RIGHT NOW')
    return


def report(msg, report_type='INFO'):

    report_string = '{}[{}] {}{}\n'
    print(report_string.format(YELLOW, report_type, NO_COLOR, msg))


def report_err(e):

    err_string = '{}[DANG] {}Something went horribly wrong:\n\t-> {}'
    print(err_string.format(RED, NO_COLOR, e))


def update():

    """
    Updates the Bucky source code from GitHub.
    """

    os.chdir(BUILD_PATH)
    sudo('git', 'pull', 'origin', 'master')


if __name__ == '__main__':

    args = parse_args()

    if args.compile_binaries:
        try:
            compile_binaries()
            sys.exit(0)
        except Exception as e:
            report_err(e)
            sys.exit(1)

    if args.remove:
        try:
            remove_bucky()
            sys.exit(0)
        except Exception as e:
            report_err(e)
            sys.exit(1)

    if args.update:
        try:
            update()
            sys.exit(0)
        except Exception as e:
            report_err(e)
            sys.exit(1)

    mesh_model = preflight(args.model)
    bucky(mesh_model)

    date_string = "{:%Y-%m-%dT%H:%M}".format(datetime.datetime.now())
    destination_dir = os.path.join(ROOT_DIR, 'generated-{}'.format(date_string))
    shutil.move(TMP_DIR, destination_dir)

    shutil.copyfile('/opt/bucky/support/cura/profile.ini',
                    os.path.join(destination_dir, 'cura_profile.ini'))

    print('--------------------------------------------------------------------------------')
    print('{}------------------------------- GREAT NEWS!!! ----------------------------------'.format(GREEN))
    print('{}--------------------------------------------------------------------------------'.format(NO_COLOR))
    report('I got all that stuff taken care of for you.', report_type='SO HEY')
    report('You can find the generated files here: \n\t{}{}'.format(GREEN, destination_dir),
           report_type='PRO TIP')

