center = [137.42, 435.73, -72.35];

neighbors = [ [146.65, 388.27, -22.27],
              [139.94, 451.32, -9.65],
              [137.35, 436.09, -72.73],
              [137.38, 435.60, -72.89] ];

connector(center, neighbors);

module connector(center, neighbors, dia_rod=5.0, dia_sphere=12, rod_wall=3, conn_len=14)
{
    // 'dia_rod': 5.0 to fit 3/16 inch (or 4.7625mm)
    
    module rod(center, neighbor, diameter, extra_len=0, t=[0, 0, 0]) {
        n = neighbor - center; // normalize center at (0, 0, 0)
        length = sqrt(n*n);
        echo(length);
        theta = acos(n * [0, 0, 1] / sqrt(n*n));
        cross_prod = cross([0, 0, 1], n);
        axis = (cross_prod == [0, 0, 0] && theta == 180) ? [1, 0, 0] : cross_prod;
        rotate(theta, axis)
        translate(t)
        cylinder(h=conn_len+extra_len, d=diameter, center=false, $fn=40);
    }

    difference() {
        union()
        {
            sphere(d=dia_sphere, $fn=80);
            for (i = [0: len(neighbors)-1]) {
                rod(center, neighbors[i], dia_rod+rod_wall);
            }
        }
        for (i = [0: len(neighbors)-1]) {
            offset = sqrt(dia_sphere*dia_sphere/4-dia_rod*dia_rod/4);
            rod(center, neighbors[i], dia_rod, 0.1, [0, 0, offset]);
        }
    }
}
