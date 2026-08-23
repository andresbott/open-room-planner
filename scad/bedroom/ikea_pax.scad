// bedroom / ikea_pax — an IKEA PAX wardrobe frame token, with a clothes hanger
// engraved on top and nothing else. The size is in the file name: a 50 cm-wide
// frame is only 10 mm across at 1:50, too narrow for a readable one.
//
// Width/Depth are the real-world frame size in cm (PAX comes 50, 75 or 100 wide,
// 58 or 35 deep). Height is the PRINTED height in mm: kept the same as the beds
// (6 mm) so every piece of the set stacks and slides on the plan.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 58;   // cm
Height = 6;    // printed height, mm

Show_hanger = true;
// Magnet pockets in the bottom face (0 = none). A 35 cm-deep frame is only 7 mm
// across at 1:50 — too narrow for a 5 mm disc, so it comes out solid unless you
// build with smaller hardware (MAGNET_D=3 MAGNET_H=2).
Magnets = 1;

ikea_pax();

module ikea_pax() {
    difference() {
        footprint(Width, Depth, Height);
        // the hanger gets the whole top face, as big as it will fit
        if (Show_hanger)
            hanger(hanger_size(cm(Width) - 2 * Symbol_margin,
                               cm(Depth) - 2 * Symbol_margin), Height);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
