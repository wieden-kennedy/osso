#!/usr/bin/env python

import datetime
import optparse
import os
import random
import shutil
import sys
import time

from sh import osso_el, osso_vn, osso_connector, openscad, sudo

OSSO_PATH = '/opt/osso'
BUILD_PATH = os.path.join(OSSO_PATH, 'build')
CONFIG_FILE = os.path.join(OSSO_PATH,'config.json')
ROOT_DIR = os.path.expanduser('~/Documents/__osso__')

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


def osso(mesh_model):

    """
    Runs all processing on the target model and converts the mesh into a set
    of vertices and connectors for output/printing.

    Args:
        mesh_model (str): the path to the mesh model to convert
    """

    # Generate all neighbors of all vertices
    report('Finding vertex neighbors from {}'.format(mesh_model))
    try:
        osso_vn(mesh_model, _out=NEIGHBORS_FILE)
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


    # Calculate edge lengths
    report('Saving edge lengths to {}.'.format(EDGE_LENGTHS_FILE))
    try:
        edge_lengths_data = osso_el(mesh_model, CONFIG_FILE,
                                     _out=EDGE_LENGTHS_FILE)
        report('Well, that worked!', report_type=random.choice(PROMPTS))
    except Exception as e:
        report_err(e)
        sys.exit(1)


    # Generate .scad
    report('Generating {} connectors to {}.'.format(num_vertices, SCAD_DIR))
    try:
        osso_connector('-n', NEIGHBORS_FILE, '-o', SCAD_DIR)
        report('I did it!', report_type='SCAD-TASTIC')
    except Exception as e:
        report_err(e)
        sys.exit(1)


    # Generate .stl
    for i in range(0, num_vertices):
        remaining = num_vertices - (i + 1)
        report('Generating connector {}...{} remaining.'.format(i + 1, remaining))
        try:
            openscad('-o',
                     os.path.join(STL_DIR, 'connector_{}.stl'.format(i)),
                     os.path.join(SCAD_DIR, 'connector_{}.scad'.format(i)))
            report('I generated that STL for ya.',
                   report_type=random.choice(PROMPTS))
        except Exception as e:
            report_err(e)
            sys.exit(1)


def compile_binaries():

    """
    Recompiles Osso's binary files using cmake.
    """

    if not os.path.exists(BUILD_PATH):
        report('Creating build path', )
        sudo.mkdir('-p', BUILD_PATH)
    else:
        report('Removing old build information')
        sudo.rm('-rf', BUILD_PATH)
        sudo.mkdir('-p', BUILD_PATH)

    os.chdir(BUILD_PATH)
    report('Compiling Osso binary files')
    sudo.cmake('..')
    sudo.make()


def parse_args():

    """
    Argument parser for this program.

    Returns:
        args (argparse.Namespace): kv tuple of arguments and their values
    """

    parser = optparse.OptionParser(conflict_handler='resolve')

    parser.add_option('-m', '--model_path', type=str, dest='model_path',
                        help='absolute path to the .obj model file')
    parser.add_option('-o', '--output-name', dest='output_name', type=str,
                        help='names the output folder under ~/Documents/__osso__')
    parser.add_option('-O', '--output-dest', dest='output_dest', type=str,
                        help='full path to custom output folder')
    parser.add_option('-c', '--compile-binaries', dest='compile_binaries',
                        action='store_true', help='used to recompile Osso\'s binaries')
    parser.add_option('-r', '--remove', action="store_true", dest='remove',
                        help='used to completely remove osso from your system')
    parser.add_option('-u', '--update', action="store_true",
                        dest='update', help='used to update the osso codebase')

    (options, args) = parser.parse_args()

    if not options.model_path:
        try:
            if not os.path.exists(sys.argv[1:][0]):
                raise OSError
            options.model_path = sys.argv[1:][0]
        except (IOError, OSError) as e:
            parser.print_help()
            parser.exit()

    return options


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


def remove_osso():

    if PYTHON_MAJOR_VERS == 2:
        prompt_func = raw_input
    else:
        prompt_func = input

    input_string = '''
    ################################################################################
    \m/~\m/~\m/~\m/~\m/~\m/~\m/~ DECIDE OSSO'S FATE!!! ~\m/~\m/~\m/~\m/~\m/~\m/~\m/
    ################################################################################

    Ok, actually, there's only one choice. Please type 'die osso die' to confirm.\n
    '''

    if prompt_func(input_string) == 'die osso die':
        print('\n\n')
        report('Reluctantly removing Osso components from your system.', report_type="SAD PANTS")
        time.sleep(1)
        sudo.rm('-rf', OSSO_PATH)
        sudo.rm('-f', '/usr/local/bin/osso')
        sudo.rm('-f', '/usr/local/bin/osso_el')
        sudo.rm('-f', 'usr/local/bin/osso_vn')
        sudo.rm('-f', '/usr/local/bin/connector')

        print('\n--------------------------------------------------------------------------------')
        print('{}------------------------------- GREAT NEWS!!! ----------------------------------'.format(GREEN))
        print('{}--------------------------------------------------------------------------------\n'.format(NO_COLOR))
        report('SUCCESS! You are now Osso-free...happy Friday! \n\tIt\'s Friday somewhere, right? \n\t\tWe can\'t really tell without Osso in our world :(',
               report_type='NOT_SUCCESS')
    else:
        print('--------------------------------------------------------------------------------')
        print('{}------------------------------- GREAT NEWS!!! ----------------------------------'.format(GREEN))
        print('{}--------------------------------------------------------------------------------\n'.format(NO_COLOR))
        report('SUCCESS! You decided to not kill Osso! \n\tWe REJOICE in your benevolent heart!!', report_type='SO OVERJOYED RIGHT NOW')
    return


def report(msg, report_type='INFO'):

    report_string = '{}[{}] {}{}\n'
    print(report_string.format(YELLOW, report_type, NO_COLOR, msg))


def report_err(e):

    err_string = '{}[DANG] {}Something went horribly wrong:\n\t-> {}'
    print(err_string.format(RED, NO_COLOR, e))


def update():

    """
    Updates the Osso source code from GitHub.
    """

    report('Updating Osso\'s source code.', report_type='JUST TRYNA MAINTAIN')
    os.chdir(BUILD_PATH)
    sudo('git', 'pull', 'origin', 'master')


if __name__ == '__main__':

    options = parse_args()

    if options.compile_binaries:
        try:
            compile_binaries()
            sys.exit(0)
        except Exception as e:
            report_err(e)
            sys.exit(1)

    if options.remove:
        try:
            remove_osso()
            sys.exit(0)
        except Exception as e:
            report_err(e)
            sys.exit(1)

    if options.update:
        try:
            update()
            sys.exit(0)
        except Exception as e:
            report_err(e)
            sys.exit(1)

    mesh_model = preflight(options.model_path)
    osso(mesh_model)

    if options.output_name:
        dest_dir = os.path.join(ROOT_DIR, options.output_name)
    elif options.output_dest:
        dest_dir = options.output_dest
    else:
        date_string = "{:%Y-%m-%dT%H:%M}".format(datetime.datetime.now())
        dest_dir = os.path.join(ROOT_DIR, 'generated-{}'.format(date_string))

    shutil.move(TMP_DIR, dest_dir)

    shutil.copyfile('/opt/osso/support/cura/profile.ini',
                    os.path.join(dest_dir, 'cura_profile.ini'))

    print('--------------------------------------------------------------------------------')
    print('{}------------------------------- GREAT NEWS!!! ----------------------------------'.format(GREEN))
    print('{}--------------------------------------------------------------------------------'.format(NO_COLOR))
    report('I got all that stuff taken care of for you.', report_type='SO HEY')
    report('You can find the generated files here: \n\t{}{}'.format(GREEN, dest_dir),
           report_type='PRO TIP')
    print(NO_COLOR)

