// kitchen / cooker — a cooker/stove token: a hob top over an oven, with the
// four hob rings engraved on top and an optional control-strip groove behind
// them, standing in for the knobs.
//
// Width/Depth are the real-world footprint in cm: a standard slot-in cooker
// is 60 cm square. Height is the real hob height — a slot-in cooker is built to
// finish level with the worktop — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 60;  // cm
Height = 90;  // cm — the hob, level with the worktop

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_hobs = true;
// A thin groove standing in for the control strip, along the back edge (+Y),
// behind the rings.
Show_controls  = true;
Control_band   = 8;  // cm reserved at the back edge for the control strip
Control_margin = 6;  // cm kept clear at each side of the groove
// Magnet pockets in the bottom face (0 = none). A near-square footprint only
// needs one central pocket to stop it pivoting; see Magnet_* in
// lib/common.scad.
Magnets = 1;

cooker();

module cooker() {
    // when the control strip is shown, the hob grid gives up a band at the
    // back edge so the two details never touch
    hob_band = Show_controls ? Control_band : 0;
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_controls)
            groove(0, Depth / 2 - Control_band / 2,
                   Width - 2 * Control_margin, Control_band / 2, Print_h);
        if (Show_hobs)
            translate([0, -cm(hob_band) / 2, 0])
                hobs(cm(Width) - 2 * Symbol_margin,
                     cm(Depth - hob_band) - 2 * Symbol_margin, Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// Four hob rings cut into the top face, in a 2x2 grid centred on the origin —
// a custom pictogram (a cooker has no equivalent in lib/common.scad), drawn
// the same way as the symbols there: stroke_arc() rings, at the label depth.
// <w> x <h> is the printed-mm patch of top face the grid may fill; each ring
// gets a quarter of it, with Symbol_margin of gap to its neighbours.
module hobs(w, h, top_z, stroke = Symbol_stroke, depth = Label_depth) {
    gap    = Symbol_margin;
    ring_d = max(Symbol_min, min(w, h) / 2 - gap);  // outer diameter
    r      = (ring_d - stroke) / 2;                 // the pen is centred on r
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            for (x = [-1, 1], y = [-1, 1])
                translate([x * w / 4, y * h / 4])
                    stroke_arc(r, 0, 360, stroke);
}
