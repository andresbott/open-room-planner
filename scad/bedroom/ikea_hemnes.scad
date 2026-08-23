// bedroom / ikea_hemnes — an IKEA HEMNES chest of drawers token, with a drawers
// symbol engraved on top and nothing else. The size is in the file name, as on the
// PAX frames.
//
// Width/Depth are the real-world footprint in cm: the HEMNES chests are 108 wide
// and 50 deep (the 3- and the 6-drawer one share that footprint, they only differ
// in height, which a plan token does not show). Height is the PRINTED height in
// mm: 6, like the rest of the set, so the pieces stack and slide on the plan.

include <../lib/common.scad>

Width  = 108;  // cm
Depth  = 50;   // cm
Height = 6;    // printed height, mm

Show_drawers = true;
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad.
Magnets = 2;

ikea_hemnes();

module ikea_hemnes() {
    difference() {
        footprint(Width, Depth, Height);
        // the drawers get the whole top face, as big as they will fit
        if (Show_drawers)
            drawers(drawers_size(cm(Width) - 2 * Symbol_margin,
                                 cm(Depth) - 2 * Symbol_margin), Height);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
