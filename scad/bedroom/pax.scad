// bedroom / pax — an IKEA PAX wardrobe frame token, with the size engraved on
// top and a groove marking the door front.
//
// Width/Depth are the real-world frame size in cm (PAX comes 50, 75 or 100 wide,
// 58 or 35 deep). Height is the PRINTED height in mm: kept the same as the beds
// (6 mm) so every piece of the set stacks and slides on the plan.
//
// The back sits against the wall at +Y — same orientation as a bed's head end —
// so the doors are marked at the -Y edge.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 58;   // cm
Height = 6;    // printed height, mm

Show_label = true;
// Door slab marked along the front edge, in real-world cm.
Front_depth = 6;
// Magnet pockets in the bottom face (0 = none). A 35 cm-deep frame is only 7 mm
// across at 1:50 — too narrow for a 5 mm disc, so it comes out solid unless you
// build with smaller hardware (MAGNET_D=3 MAGNET_H=2).
Magnets = 1;

pax();

module pax() {
    txt = str(Width, "x", Depth);
    difference() {
        footprint(Width, Depth, Height);
        // doors, marked at the -Y front
        groove(0, -(Depth / 2 - Front_depth / 2), Width, Front_depth, Height);
        // label centred on what is left of the top face above the door groove
        if (Show_label)
            translate([0, cm(Front_depth) / 2, 0])
                label(txt, Height,
                      size = label_size_for(txt, cm(Width) - 2 * Label_margin));
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
