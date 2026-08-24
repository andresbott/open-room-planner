// kidsroom / changing_table — a baby changing table token: drawer fronts
// engraved on top, plus a low raised guard rim around the top edge so the
// piece reads as somewhere a baby is kept from rolling off.
//
// Width/Depth are the real-world footprint in cm (a changing table is close
// to a chest of drawers in size: about 80 wide, 50 deep). Height is the real height
// of the changing surface — waist height, so a baby can be reached without
// stooping — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad); the guard rim stands its own real height on top of that.

include <../lib/common.scad>

Width  = 80;  // cm
Depth  = 50;  // cm
Height = 90;  // cm — the changing surface

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_drawers = true;
Show_rim     = true;
// The guard rim: how far in from the edge the raised band reaches, in real
// cm, and how it is built. It reuses cushion()'s self-tapering hull — sides
// slope, so it prints without support, unlike a thin tall wall — but with a
// smaller radius/taper than the Cushion_* defaults, which are sized for a
// full pillow and would collapse a band this narrow to nothing.
Rim_w      = 6;    // cm
Rim_h      = 8;    // cm the rim stands above the surface
Rim_taper  = 0.3;  // mm
Rim_radius = 0.3;  // mm
// Magnet pockets in the bottom face, in a row along the width (0 = none).
// Two keep the piece from pivoting; the 50 cm depth is still 12.5 mm at 1:40,
// wide enough for the 4 mm disc; see Magnet_* in lib/common.scad.
Magnets = 2;

changing_table();

module changing_table() {
    // with the rim up, keep the drawers inside the well it leaves; with it
    // off, let the drawers use the whole top face, as in ikea_hemnes.scad
    patch_w = Show_rim ? cm(Width - 2 * Rim_w) - 2 * Symbol_margin
                        : cm(Width) - 2 * Symbol_margin;
    patch_h = Show_rim ? cm(Depth - 2 * Rim_w) - 2 * Symbol_margin
                        : cm(Depth) - 2 * Symbol_margin;
    union() {
        difference() {
            footprint(Width, Depth, Print_h);
            if (Show_drawers)
                drawers(drawers_size(patch_w, patch_h), Print_h);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_rim) guard_rim();
    }
}

// The guard rim: four cushion()-style pads butted at the corners — two
// full-width bars along the front/back edges and two shorter bars along the
// sides, tiling a shallow raised frame around the top. Each pad is its own
// low, self-tapering hull (see cushion() in lib/common.scad), so the frame
// prints flat with no support, unlike a thin tall wall.
module guard_rim() {
    for (s = [-1, 1]) {
        translate([0, s * cm(Depth - Rim_w) / 2, 0])
            cushion(Width, Rim_w, Print_h, Rim_h, Rim_taper, Rim_radius);
        translate([s * cm(Width - Rim_w) / 2, 0, 0])
            cushion(Rim_w, Depth - 2 * Rim_w, Print_h, Rim_h, Rim_taper, Rim_radius);
    }
}
