// kidsroom / bunk_bed — two stacked single beds sharing one footprint, with a
// ladder hint engraved at one end and the mattress size at the other.
//
// Width/Length are the real-world footprint in cm: a bunk stands on the same
// floor space as a single bed, it just carries a second one above it. Height is the
// real height over the top bunk's guard rail, shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad) — so the token comes out as tall as
// a wardrobe on a single bed's footprint, which is exactly what a bunk is.

include <../lib/common.scad>

Width  = 90;   // cm — single-bed width
Length = 200;  // cm — single-bed length
Height = 165;  // cm — over the top bunk's guard rail

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_ladder = true;
Show_label  = true;
// Ladder hint, in real-world cm: two side rails and a few rungs between them,
// engraved at one end of the piece — where the real ladder climbs to the top
// bunk.
Ladder_span  = 70;  // how much of the length the rails run over
Ladder_inset = 14;  // gap from the end of the piece to the ladder
Ladder_rungs = 4;   // rungs between the rails, including the two end ones

// Magnet pockets in the bottom face, in a row along the length (0 = none). Two
// keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
Magnets = 2;

bunk_bed();

module bunk_bed() {
    // the ladder sits Ladder_inset in from the +Y end, Ladder_span long
    ladder_y = cm(Length) / 2 - cm(Ladder_inset) - cm(Ladder_span) / 2;
    difference() {
        footprint(Width, Length, Print_h);
        if (Show_ladder)
            translate([0, ladder_y, 0])
                ladder(cm(Width) - 2 * Symbol_margin, cm(Ladder_span), Print_h,
                       rungs = Ladder_rungs);
        if (Show_label)
            translate([0, -cm(Length) / 6, 0])
                label(str(Width, "x", Length), Print_h);
        if (Magnets > 0)
            magnets(Width, Length, Magnets);
    }
}

// A ladder cut into the top face — two side rails <w> mm apart, joined by
// <rungs> rungs over <h> mm of length between them, drawn with the same pen as
// hanger()/drawers() (stroke_line(), round-ended) and centred on the origin.
// Follows the custom-detail pattern from lib/common.scad (a shallow cut at
// Label_depth, translated down from the top face before the 2D strokes are
// extruded).
module ladder(w, h, top_z, stroke = Symbol_stroke, depth = Label_depth,
              rungs = Ladder_rungs) {
    // the pen is centred on the path, so the paths span one stroke less than
    // the w x h patch they have to fit in (as in hanger()/drawers())
    pw = w - stroke;
    ph = h - stroke;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                for (s = [-1, 1])                        // the two side rails
                    stroke_line([s * pw / 2, -ph / 2], [s * pw / 2, ph / 2], stroke);
                for (i = [0 : rungs - 1]) {               // the rungs between them
                    y = rungs > 1 ? -ph / 2 + i * ph / (rungs - 1) : 0;
                    stroke_line([-pw / 2, y], [pw / 2, y], stroke);
                }
            }
}
