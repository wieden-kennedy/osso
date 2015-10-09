center = [0, 0, 0]; // v[9]

neighbors = [ [0, 0, 1],
              [0, 0, -1],
              [-1, 0, 0],
              [1, 0, 0] ];

connector(center, neighbors);

module connector(center, neighbors)
{
    rod_diameter = 5;    // 3/16 inch = 4.7625mm
    conn_thick   = 3;
    conn_len     = 10;

    module rod(center, neighbor, diameter, extra_len) {
        n = neighbor - center; // normalize center at (0, 0, 0)
        length = sqrt(n*n);
        echo(length);
        theta = acos(n * [0, 0, 1] / sqrt(n*n));
        cross_prod = cross([0, 0, 1], n);
        axis = (cross_prod == [0, 0, 0] && theta == 180) ? [1, 0, 0] : cross_prod;
        rotate(theta, axis)
        translate(0, 0, 100)
        cylinder(h = conn_len + extra_len, d = diameter, center = false, $fn = 40);
    }

    difference() {
        union()
        {
            for (i = [0: len(neighbors)-1]) {
                rod(center, neighbors[i], rod_diameter+conn_thick, 0);
            }
        }
        for (i = [0: len(neighbors)-1]) {
            rod(center, neighbors[i], rod_diameter, 0.1);
        }
    }
}
