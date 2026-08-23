// bedroom / bed — a mattress-footprint token with the size engraved on top and
// a groove marking the head end.
//
// Width/Length are the real-world mattress size in cm (IKEA naming, e.g.
// 160x200). Height is the PRINTED height in mm: kept low so the pieces stack
// and slide on the plan (the existing 1:50 set uses 6 mm for beds).

include <../lib/common.scad>

Width  = 160;  // cm
Length = 200;  // cm
Height = 6;    // printed height, mm

Show_label = true;
// Depth of the pillow/head-end marking, in real-world cm.
Head_depth = 30;
// Magnet pockets in the bottom face, in a row along the length (0 = none).
// Two keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
Magnets = 2;

bed();

module bed() {
    difference() {
        footprint(Width, Length, Height);
        // head end, marked at the +Y side
        groove(0, Length / 2 - Head_depth / 2, Width, Head_depth, Height);
        if (Show_label)
            translate([0, -cm(Length) / 6, 0])
                label(str(Width, "x", Length), Height);
        if (Magnets > 0)
            magnets(Width, Length, Magnets);
    }
}
