rod_diameter = 6;   // in millimeters
wall_thickness = 2;
tube_length = 20;
angle = 15;         // degrees
   
// Connector as a solid object (no holes)
module solid() {
    cylinder(r = rod_diameter + wall_thickness * 2, h = tube_length);
    translate([0, 0, -tube_length]) 
        cylinder(r = rod_diameter + wall_thickness * 2, h = tube_length);
    rotate([0, 90, angle]) 
        cylinder(r = rod_diameter + wall_thickness * 2, h = tube_length);
    rotate([0, 90, 180-angle]) 
        cylinder(r = rod_diameter + wall_thickness * 2, h = tube_length);
}
   
// Object representing the space for the rods.
module hole_cutout() {
    cut_overlap = 0.2; // Extra length to make clean cut out of main shape
    cylinder(r = rod_diameter, h = tube_length + cut_overlap);
    translate([0, 0, -tube_length-cut_overlap]) 
        cylinder(r = rod_diameter, h = tube_length + cut_overlap);
    rotate([0, 90, angle]) 
        cylinder(r = rod_diameter, h = tube_length + cut_overlap);
    rotate([0, 90, 180-angle]) 
        cylinder(r = rod_diameter, h = tube_length + cut_overlap);
}
   
difference() {
    solid();
    hole_cutout();
}