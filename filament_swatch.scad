/* [Swatch Dimensions] */
// Total height of the swatch
height = 35; // [10:1:100]
// Total width of the swatch
width = 60; // [10:1:150]
// Thickness of the swatch
thickness = 2; // [0.4:0.2:10]
// Corner radius
corner_radius = 3; // [0:0.5:15]

/* [Hole] */
// Diameter of the hanging hole
hole_diameter = 5; // [2:0.5:20]
// Distance from hole center to nearest edge
hole_edge_distance = 5; // [2:0.5:30]
// Hole position on the swatch
hole_position = "center"; // [center, top]

/* [Hidden] */
$fn = 64;

module rounded_rect(w, h, t, r) {
    r = min(r, min(w, h) / 2);
    linear_extrude(t)
        offset(r)
            square([w - 2 * r, h - 2 * r], center = true);
}

module swatch() {
    hole_r = hole_diameter / 2;

    hole_x = 0;
    hole_y = (hole_position == "top")
        ? height / 2 - hole_edge_distance
        : 0;

    difference() {
        rounded_rect(width, height, thickness, corner_radius);
        translate([hole_x, hole_y, -0.5])
            cylinder(h = thickness + 1, r = hole_r);
    }
}

swatch();
