#
# $ pip install solidpython
#

import json
from solid import *
use('connector.scad')

centers = []
neighbors = []

if len(sys.argv) < 3:
    print 'Usage:  python connector.py <neighbors.txt> <output_folder>'
    sys.exit(0)

neighbors_file = sys.argv[1]
output_folder = sys.argv[2]

with open(neighbors_file) as f:
    line = f.readline()
    line = f.readline()
    while True:
        line = f.readline()
        if not line:
            break
        v = [float(line.strip().split()[i]) for i in range(1,4)]
        centers.append(v)
        vv = []
        while True:
            line = f.readline()
            if not line.strip():
                neighbors.append(vv)
                break
            vv.append([float(line.strip().split()[i]) for i in range(1,4)])

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

with open('config.json') as f:
    params = json.loads(f.read())

for i in range(len(centers)):
    model = connector(centers[i], neighbors[i], params['dia_rod'], params['dia_sphere'], params['rod_wall'], params['conn_len'])
    scad_render_to_file(model, output_folder + '/conn' + str(i) + '.scad')
