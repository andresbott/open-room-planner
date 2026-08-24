// kitchen / island — a kitchen island token, with a run of vertical seams
// engraved along one long side to hint at the cabinet and drawer fronts a
// real island carries there.
//
// Width/Depth are the real-world footprint in cm: a 120x90 island, worktop
// height. Height is that real worktop height, shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad), so the island comes out level
// with the rest of the kitchen run.

include <../lib/common.scad>

Width  = 120;  // cm
Depth  = 90;   // cm
Height = 90;   // cm — standard worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_fronts = true;
// The fronts sit along the +Y long side, drawn as a run of vertical seams cut
// with groove() rather than the drawers() symbol: an island's fronts run
// side by side along its length, they do not stack like a chest's.
Front_count  = 4;    // fronts along that side, i.e. Front_count - 1 seams
Front_margin = 6;    // cm kept clear at each end of the run, past the corners
Seam_w       = 2.5;  // cm, real-world width of a seam cut
Seam_d       = 14;   // cm, how far a seam reaches in from the edge
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad.
Magnets = 2;

island();

module island() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_fronts) fronts(Print_h);
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// A run of vertical seams along the +Y long side, marking where one
// cabinet/drawer front ends and the next begins.
module fronts(top_z) {
    y    = Depth / 2 - Seam_d / 2;
    span = Width - 2 * Front_margin;
    for (i = [1 : Front_count - 1])
        groove(-Width / 2 + Front_margin + i * span / Front_count, y,
               Seam_w, Seam_d, top_z);
}
