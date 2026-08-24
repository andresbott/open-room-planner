// bedroom / ikea_pax — an IKEA PAX wardrobe frame token, with a clothes hanger
// engraved on top and nothing else. The size is in the file name: a 50 cm-wide
// frame is only 12.5 mm across at 1:40, too narrow for a readable one.
//
// Width/Depth are the real-world frame size in cm (PAX comes 50, 75 or 100 wide,
// 58 or 35 deep) and Height its real height — the tall 236 cm frame, or 201 for
// the short one. All three are shrunk by the plan scale (see printed_h() in
// lib/common.scad), so a PAX frame is one of the tallest pieces of the set.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 58;   // cm
Height = 236;  // cm — the tall frame (201 for the short one)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_hanger = true;
// Magnet pockets in the bottom face, in a row along the width (0 = none). A 35 cm-deep
// frame is 8.75 mm across at 1:40 — wide enough for a 4 mm disc. One is enough on the
// narrow frames; the 100 cm-wide ones are 25 mm long and take two, so they cannot
// pivot on the plan (the Makefile asks for them).
Magnets = 1;

ikea_pax();

module ikea_pax() {
    difference() {
        footprint(Width, Depth, Print_h);
        // the hanger gets the whole top face, as big as it will fit
        if (Show_hanger)
            hanger(hanger_size(cm(Width) - 2 * Symbol_margin,
                               cm(Depth) - 2 * Symbol_margin), Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
