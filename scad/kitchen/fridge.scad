// kitchen / fridge — a freestanding fridge-freezer token, with a door seam
// and a handle engraved on top.
//
// Width/Depth are the real-world footprint in cm: a fridge-freezer combi runs
// close to square, about 60x60 (an American-style side-by-side is much
// bigger — try Width = 90, Depth = 70). Height is the real case height — a tall
// freestanding combi — shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad), so it stands with the larder units and the wardrobes.

include <../lib/common.scad>

Width  = 60;   // cm — American-style side-by-side: Width = 90, Depth = 70
Depth  = 60;   // cm
Height = 185;  // cm — a tall freestanding fridge-freezer

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_doors = true;
// The seam between the fridge (upper) and freezer (lower) doors, and a short
// handle mark on the fridge door, cut with groove() rather than a symbol. The
// two doors stack in elevation, not across the floor, so +Y stands for "up"
// here — the same locally-flattened convention drawers() uses, not a real
// front/back edge of the footprint. A bottom-freezer combi keeps the freezer
// to roughly a third of the case.
Freezer_depth = 20;  // cm, how much of Depth the freezer (lower) door takes
Handle_len    = 12;  // cm, length of the handle groove
Handle_inset  = 8;   // cm, how far the handle sits in from the door's side edge

// Magnet pockets in the bottom face (0 = none). The footprint is near-square,
// so one central pocket is enough to stop it pivoting; a 60 cm side is 15 mm
// at 1:40, comfortably wide enough for the 4 mm disc (see Magnet_* in
// lib/common.scad).
Magnets = 1;

fridge();

module fridge() {
    stroke = Symbol_stroke * Scale / 10;  // cm that prints Symbol_stroke wide
    margin = Symbol_margin * Scale / 10;  // cm that prints Symbol_margin wide
    // seam offset from centre: the freezer (lower) keeps the bottom
    // Freezer_depth cm, the fridge (upper) gets the rest
    seam_y = Freezer_depth - Depth / 2;
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_doors) {
            // the seam, splitting the fridge (upper) door from the freezer
            // (lower) door, almost the full width of the case
            groove(0, seam_y, Width - 2 * margin, stroke, Print_h);
            // a short handle mark on the fridge door, near its side edge
            groove(Width / 2 - Handle_inset, (seam_y + Depth / 2) / 2,
                   stroke, Handle_len, Print_h);
        }
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
