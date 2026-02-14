/* [Swatch Dimensions] */
// Total height of the swatch
height = 35; // [10:1:100]
// Total width of the swatch
width = 60; // [10:1:150]
// Thickness of the swatch
thickness = 2; // [0.4:0.2:10]
// Corner radius
corner_radius = 3; // [0:0.5:15]

/* [Text] */
// Brand name
brand = "Brand";
// Filament type (e.g. PLA, PETG, ASA)
type = "PLA";
// Color name
color_name = "Color";
// SKU (leave blank to hide)
sku = "";
// Nozzle size in mm
nozzle_size = "0.6";
// Layer thickness in mm
layer_thickness = "0.3";
// Font size
font_size = 5; // [3:0.5:12]
// Text depth (positive = embossed, negative = engraved)
text_depth = 0.4; // [-2:0.1:2]

/* [Hole] */
// Diameter of the hanging hole
hole_diameter = 8; // [2:0.5:20]
// Distance from hole edge to nearest swatch edge
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

module swatch_text() {
    lines = [brand, type, color_name, sku];
    line_spacing = font_size * 1.6;
    // Always lay out based on 4 lines so positions are stable
    block_height = 3 * line_spacing;

    // Left-aligned text offset from left edge
    text_x = -width / 2 + corner_radius + 1;

    for (i = [0 : 3]) {
        if (i < 3 || lines[i] != "")
            translate([text_x, block_height / 2 - i * line_spacing, thickness])
                linear_extrude(abs(text_depth))
                    text(lines[i], size = font_size, font = "Liberation Sans:style=Bold",
                         halign = "left", valign = "center");
    }

    // Nozzle size x layer thickness at bottom right
    noz_label = str(nozzle_size, " x ", layer_thickness);
    translate([width / 2 - corner_radius - 1, -height / 2 + corner_radius + font_size / 2 + 1, thickness])
        linear_extrude(abs(text_depth))
            text(noz_label, size = font_size, font = "Liberation Sans:style=Bold",
                 halign = "right", valign = "center");
}

module diamond_grid() {
    grid_size = 15;      // 15mm x 15mm total area
    diamond_size = 2;    // bounding box of each diamond
    spacing = 1;         // gap between diamonds
    pitch = diamond_size + spacing;
    count = floor(grid_size / pitch);
    side = diamond_size / sqrt(2);
    grid_extent = (count - 1) * pitch;

    // Centered vertically, 2mm to the left of the hole edge
    hole_left_edge = width / 2 - hole_edge_distance - hole_diameter;
    offset_x = hole_left_edge - 2 - grid_extent / 2;
    offset_y = 0;
    translate([offset_x, offset_y, -0.5])
        for (ix = [0 : count - 1])
            for (iy = [0 : count - 1])
                translate([ix * pitch - grid_extent / 2,
                           iy * pitch - grid_extent / 2, 0])
                    rotate([0, 0, 45])
                        linear_extrude(thickness + abs(text_depth) + 1)
                            square([side, side], center = true);
}

module diamond_cuts() {
    difference() {
        diamond_grid();
        // Protect text areas from diamond cuts
        translate([0, 0, -1])
            linear_extrude(thickness + abs(text_depth) + 2)
                projection()
                    swatch_text();
    }
}

module swatch() {
    hole_r = hole_diameter / 2;

    // Right side: hole edge is hole_edge_distance from the right edge
    hole_x = width / 2 - hole_edge_distance - hole_r;
    // Top: hole edge is hole_edge_distance from top edge; Center: vertically centered
    hole_y = (hole_position == "top")
        ? height / 2 - hole_edge_distance - hole_r
        : 0;

    if (text_depth >= 0) {
        // Embossed: base + raised text
        difference() {
            rounded_rect(width, height, thickness, corner_radius);
            translate([hole_x, hole_y, -0.5])
                cylinder(h = thickness + abs(text_depth) + 1, r = hole_r);
            diamond_cuts();
        }
        intersection() {
            rounded_rect(width, height, thickness + abs(text_depth), corner_radius);
            swatch_text();
        }
    } else {
        // Engraved: cut text into the top surface
        difference() {
            rounded_rect(width, height, thickness, corner_radius);
            translate([hole_x, hole_y, -0.5])
                cylinder(h = thickness + 1, r = hole_r);
            translate([0, 0, -abs(text_depth)])
                swatch_text();
            diamond_cuts();
        }
    }
}

swatch();
