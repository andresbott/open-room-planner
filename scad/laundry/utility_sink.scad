// laundry / utility_sink — a deep single-basin utility sink token, with an
// inset basin rim groove and a tap ring engraved on top.
//
// Width/Depth are the real-world footprint in cm: 60 x 50 is a common
// single-basin utility/laundry sink size. Height is the real height of the rim —
// worktop height — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad).

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 50;  // cm
Height = 90;  // cm — the rim, at worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_basin = true;
// How far the basin rim is set in from the footprint edge, in real-world cm —
// the flat lip of a real utility sink before the bowl drops away.
Basin_inset = 9;  // cm
// Tap-ring radius, printed mm — a drawing detail, so it does not scale.
Tap_r = 1;  // mm
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; a 50 cm depth is 12.5 mm at 1:40, comfortably
// wide enough for the 4 mm disc, and the 60 cm width (15 mm) has room for the
// pair with a wall between them (see Magnet_* in lib/common.scad).
Magnets = 2;

utility_sink();

module utility_sink() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_basin)
            basin(Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The basin: an inset rounded-rectangle rim groove with a tap ring set back
// toward its rear (+Y) inside edge, both cut into the top face at the same
// depth as label().
module basin(top_z, depth = Label_depth, stroke = Symbol_stroke) {
    basin_w  = Width - 2 * Basin_inset;
    basin_d  = Depth - 2 * Basin_inset;
    inner_y  = cm(basin_d) / 2 - stroke / 2;  // the groove's inside edge
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                // the rim: an outline, not a filled cut, so the bowl reads hollow
                difference() {
                    offset(delta =  stroke / 2) footprint_2d(basin_w, basin_d);
                    offset(delta = -stroke / 2) footprint_2d(basin_w, basin_d);
                }
                // the tap, as far back as it fits without crowding the rim
                translate([0, inner_y - Symbol_margin - Tap_r])
                    stroke_arc(Tap_r, 0, 360, stroke);
            }
}
