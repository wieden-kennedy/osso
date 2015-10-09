from openmesh import *

vid = 39
mesh = TriMesh()
read_mesh(mesh, "B2_WIP.obj")

for vh in mesh.vertices():
    if vh.idx() == vid:
        p = mesh.point(vh)
        print "v[%d]: %.2f, %.2f, %.2f" % (vid, p[0], p[1], p[2])
        for neighbor in mesh.vv(vh):
            n = mesh.point(neighbor)
            print "v[%d]: %.2f, %.2f, %.2f" % (neighbor.idx(), n[0], n[1], n[2])
