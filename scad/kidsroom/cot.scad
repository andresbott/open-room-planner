// kidsroom / cot — a baby's cot token, with a barred rail engraved on top and
// an optional raised mattress pad.
//
// Width/Length are the real-world cot footprint in cm (a standard cot
// mattress is 60x120). Height is the real height over the barred rail — waist
// height on an adult, so a cot is not as low as a bed — shrunk by the plan scale
// like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 60;   // cm
Length = 120;  // cm
Height = 90;   // cm — over the rail

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_slats = true;
// The rail/bars pattern, in printed mm — drawing detail, so it does not scale
// (like Symbol_stroke/Symbol_margin in lib/common.scad).
Rail_inset = 1.5;  // gap between the rail outline and the footprint edge
Bar_len    = 1.8;  // how far a bar reaches in from the rail
Bar_gap    = 2.6;  // spacing between bar centres along a long side

// A raised mattress pad, off by default so the bars read clearly on their own;
// switch it on for a softer look. Both real cm, like Pillow_gap in bed.scad.
Show_mattress = false;
Mattress_gap  = 4;   // cm, mattress inset from the rail on every side
Mattress_h    = 8;   // cm the pad stands above the rail

// Magnet pockets in the bottom face, in a row along the length (0 = none).
// Two keep the piece from pivoting; see Magnet_* in lib/common.scad. A 60 cm
// width is 15 mm at 1:40, wide enough for the disc.
Magnets = 2;

cot();

module cot() {
    union() {
        difference() {
            footprint(Width, Length, Print_h);
            if (Show_slats)
                detail(Print_h);
            if (Magnets > 0)
                magnets(Width, Length, Magnets);
        }
        // a soft mattress pad, inset from the rail
        if (Show_mattress)
            cushion(Width - 2 * Mattress_gap, Length - 2 * Mattress_gap,
                    Print_h, Mattress_h);
    }
}

// The crib bars cut into the top face: a rail outline set in from the edge,
// plus a row of short bars stepping along each long side, standing in for
// the vertical bars a real cot is barred with. No ready-made helper fits a
// barred rail, so this is a custom pictogram, drawn with the same pen as
// hanger()/drawers().
module detail(top_z, depth = Label_depth) {
    hw   = cm(Width)  / 2 - Rail_inset;      // half-extents of the rail
    hl   = cm(Length) / 2 - Rail_inset;
    bars = max(2, round(2 * hl / Bar_gap));  // evenly spaced along each side
    step = 2 * hl / bars;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                // the rail: an outline set in from the footprint edge
                for (s = [-1, 1]) {
                    stroke_line([-hw, s * hl], [hw, s * hl], Symbol_stroke);
                    stroke_line([s * hw, -hl], [s * hw, hl], Symbol_stroke);
                }
                // the bars: short ticks along each long side, anchored on
                // the rail and pointing in
                for (s = [-1, 1])
                    for (i = [0 : bars])
                        translate([0, -hl + i * step])
                            stroke_line([s * hw, 0], [s * (hw - Bar_len), 0],
                                        Symbol_stroke);
            }
}
