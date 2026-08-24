// diningroom / sideboard — a dining sideboard/buffet token: a drawer band
// engraved across the back of the top face, with vertical door seams marking
// the cabinet doors below it.
//
// Width/Depth are the real-world footprint in cm: 180 wide, 45 deep, a
// standard sideboard/buffet size. Height is the real height of the carcass —
// about hip height, like a chest of drawers — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 180;  // cm
Depth  = 45;   // cm
Height = 85;   // cm — a buffet stands a touch taller than a table

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_fronts = true;
Drawer_rows = 2;  // drawer fronts stacked in the band across the back
Doors       = 3;  // cabinet doors below the drawers; seams engraved between them
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the long, narrow piece from pivoting on the board; see Magnet_* in
// lib/common.scad — 45 cm of depth is 11.25 mm at 1:40, plenty for the 4 mm disc.
Magnets = 2;

sideboard();

module sideboard() {
    // the top face reads like a flattened front elevation: a drawer band
    // across the back (+Y), and below it toward the front (-Y) the cabinet
    // doors — marked only by the seams between them, cut with groove().
    band_d     = Depth * 0.4;                  // cm the drawer band takes
    door_d     = Depth * 0.5;                  // cm left for the door seams
    band_y     =  Depth / 2 - band_d / 2 - 1;  // 1 cm off the back edge
    door_y     = -Depth / 2 + door_d / 2 + 1;  // 1 cm off the front edge
    band_w_mm  = cm(Width) - 2 * Symbol_margin;
    band_h_mm  = cm(band_d);
    band_ratio = band_w_mm / band_h_mm;  // = w/h, so the band fills its patch
    // a seam this wide prints Symbol_stroke regardless of Scale
    seam_w     = Symbol_stroke * Scale / 10;

    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_fronts) {
            translate([0, cm(band_y), 0])
                drawers(drawers_size(band_w_mm, band_h_mm, Symbol_size, band_ratio),
                        Print_h, ratio = band_ratio, rows = Drawer_rows);
            for (i = [1 : Doors - 1])
                groove(-Width / 2 + i * Width / Doors, door_y, seam_w, door_d, Print_h);
        }
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
