// kitchen / sink — a base cabinet with a sink basin and tap engraved into the
// worktop, and nothing else.
//
// Width/Depth are the real-world cabinet footprint in cm: 80 cm wide, 60 cm
// deep — the standard worktop depth. Height is the real worktop height, shrunk by
// the plan scale like the footprint (see printed_h() in lib/common.scad), so the
// sink comes out level with the rest of the run.

include <../lib/common.scad>

Width  = 80;  // cm
Depth  = 60;  // cm
Height = 90;  // cm — standard worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_basin = true;
// How far the basin rim sits in from the cabinet edges, in real-world cm — the
// worktop upstand and draining board left around the bowl.
Basin_inset = 11;  // cm
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad.
Magnets = 2;

sink();

module sink() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_basin)
            basin(Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The basin cut into the top face: an inset rounded-rectangle rim (the bowl,
// Basin_inset cm in from every edge) with a tap ring in the deck behind it
// (+Y), drawn with the same pen as hanger()/drawers() so it reads like the
// rest of the set.
module basin(top_z, depth = Label_depth, stroke = Symbol_stroke) {
    pw    = cm(Width - 2 * Basin_inset);    // rim centreline, mm
    ph    = cm(Depth - 2 * Basin_inset);
    lo    = ph / 2;                         // the rim's back edge
    hi    = cm(Depth) / 2 - Symbol_margin;  // closest the tap may sit to the edge
    tap_y = (lo + hi) / 2;
    tap_r = max(stroke, (hi - lo) / 2 - stroke / 2);
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                for (s = [-1, 1]) {                     // the rim
                    stroke_line([-pw / 2, s * ph / 2], [pw / 2, s * ph / 2], stroke);
                    stroke_line([s * pw / 2, -ph / 2], [s * pw / 2, ph / 2], stroke);
                }
                translate([0, tap_y]) stroke_arc(tap_r, 0, 360, stroke);  // the tap
            }
}
