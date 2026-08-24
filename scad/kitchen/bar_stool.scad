// kitchen / bar_stool — a round bar stool token, with a seat ring engraved on
// top and nothing else.
//
// Diameter is the real-world seat size in cm: a bar stool seat is a narrow
// round disc, commonly 30-40 cm across. Height is the real seat height: a bar stool
// puts the seat up at a raised worktop / breakfast bar, so it stands taller than a
// dining chair and is shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad).

include <../lib/common.scad>

Diameter = 35;  // cm
Height   = 65;  // cm — seat height at a breakfast bar

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_seat = true;
// Magnet pockets in the bottom face (0 = none). A 35 cm disc is only 8.75 mm
// across at 1:40 — just enough for the 4 mm disc; a smaller stool drops to the
// 2 mm one on its own (see Magnet_* in lib/common.scad).
Magnets = 1;

bar_stool();

module bar_stool() {
    difference() {
        footprint_round(Diameter, Print_h);
        // a seat ring set in from the rim, as big as the top face allows
        if (Show_seat)
            detail(Print_h);
        if (Magnets > 0)
            magnets(Diameter, Diameter, Magnets);
    }
}

// The seat ring, cut into the top face at the same depth as label() — a single
// stroke_arc traced just inside the rim, kept Symbol_margin off the edge and
// Symbol_stroke wide, centred on the origin.
module detail(top_z, depth = Label_depth) {
    r = cm(Diameter) / 2 - Symbol_margin - Symbol_stroke / 2;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            stroke_arc(r, 0, 360, Symbol_stroke);
}
