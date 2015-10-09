
module tube(height, diameter, thickness)
{
    difference() {
        cylinder(h = height, d = diameter+thickness, center = true, $fn = 40);
        cylinder(h = height+0.1, d = diameter, center = true, $fn = 40);
    }
}

tube(10, 4.8, 1);

translate([0, 10, 0])
tube(10, 4.9, 2);

translate([0, 20, 0])
tube(10, 5.0, 3);


