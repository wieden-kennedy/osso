#!/usr/bin/python

import json
import os
import sys

import solid.solidpython as solid


def centers_neighbors(neighbors_file):
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


def preflight():
    if len(sys.argv) < 3:
        print('Usage: python connector.py <neighbors.txt> <output_folder>')
        sys.exit(0)

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    return sys.argv[1:]


def render_to_file(centers, neighbors, out_path):
    solid.use('./connector.scad')

    with open('./config.json') as f:
        params = json.loads(f.read())

    for i, center in enumerate(centers):
        # connector object injected into current ns by `solid.use`
        model = connector(center, neighbors[i],
                          params['dia_rod'], params['dia_sphere'],
                          params['rod_wall'], params['conn_len'])

        file_name = '{}.scad'.format(i)
        path = os.path.join(output_path, 'conn', file_name)

        solid.scad_render_to_file(model, file_path)


if __name__ == '__main__':

    output_folder, neighbors_file = preflight()
    centers, neighbors = centers_neighbors(neighbors_file)

    render_to_file(centers, neighbors, output_folder)
