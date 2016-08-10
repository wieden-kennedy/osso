#!/usr/bin/python

import argparse
import json
import os
import sys

from solid import *


def centers_neighbors(neighbors_file):
    """
    Method that extracts vertex centers and their neighbors from the
    given neighbors stl file.

    Args:
        neighbors_file (str): the path to the neighbors file to parse.

    Returns:
        centers (list[float]): a list of the vertex centers
        neighbors (list[float]: a list of the neighbors for each vertex
    """

    centers = []
    neighbors = []

    with open(neighbors_file) as f:
        line = f.readline()
        line = f.readline()
        while True:
            line = f.readline()
            if not line:
                break
            v = [float(line.strip().split()[i + 1]) for i in range(3)]
            centers.append(v)

            vv = []
            while True:
                line = f.readline()
                if not line.strip():
                    neighbors.append(vv)
                    break
                vv.append([float(line.strip().split()[i + 1]) for i in range(3)])

    return centers, neighbors


def parse_args():

    """
    Argument parser for this program.

    Returns:
        args (argparse.Namespace): kv tuple of arguments and their values
    """

    parser = argparse.ArgumentParser()

    parser.add_argument("-o", "--output-path", type=str,
                        help="where to store the generated stl files")
    parser.add_argument('-n', '--neighbor-file', type=str,
                        help='where the vertex neighbors are defined')

    if len(sys.argv[1:]) == 0:
        parser.print_help()
        parser.exit()

    return parser.parse_args()


def render_to_file(centers, neighbors, out_path):

    """
    Uses a SCAD model to render the vertex connections as 3D-printable models

    Args:
        centers (list[float]): a list of vertex centers
        neighbors (list[float]): a list of vertex neighbors
        out_path (str): the path to which the model files should be written

    """

    use('/opt/open-vertex/scripts/connector.scad')

    with open('/opt/open-vertex/scripts/config.json') as f:
        params = json.loads(f.read())

    for i, center in enumerate(centers):
        # connector object injected into current ns by `solid.use`
        model = connector(center, neighbors[i],
                          params['dia_rod'], params['dia_sphere'],
                          params['rod_wall'], params['conn_len'])

        file_name = '{}.scad'.format(i)
        render_path = os.path.join(out_path, 'conn')

        if not os.path.exists(render_path):
            os.makedirs(render_path)

        scad_render_to_file(model, os.path.join(render_path, file_name))


if __name__ == '__main__':

    args = parse_args()

    if not os.path.exists(args.output_path):
        os.makedirs(args.output_path)

    centers, neighbors = centers_neighbors(args.neighbor_file)
    render_to_file(centers, neighbors, args.output_path)
