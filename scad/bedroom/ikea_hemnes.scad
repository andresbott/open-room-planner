// bedroom / ikea_hemnes — an IKEA HEMNES chest of drawers token, with a drawers
// symbol engraved on top and nothing else. The size is in the file name, as on the
// PAX frames.
//
// Width/Depth are the real-world footprint in cm — the HEMNES chests are 108 wide
// and 50 deep — and Height the real height of the carcass: 96 for the 3-drawer and
// the 8-drawer chest, 131 for the tall 6-drawer one on the same footprint. All
// three are shrunk by the plan scale (see printed_h() in lib/common.scad), so a
// chest stands well clear of a bed and well short of a wardrobe.

include <../lib/common.scad>

Width  = 108;  // cm
Depth  = 50;   // cm
Height = 96;   // cm — 3-drawer / 8-drawer carcass (131 for the 6-drawer)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_drawers = true;
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad.
Magnets = 2;

ikea_hemnes();

module ikea_hemnes() {
    difference() {
        footprint(Width, Depth, Print_h);
        // the drawers get the whole top face, as big as they will fit
        if (Show_drawers)
            drawers(drawers_size(cm(Width) - 2 * Symbol_margin,
                                 cm(Depth) - 2 * Symbol_margin), Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
