// hallway / shoe_cabinet — a shallow shoe cabinet token, with horizontal seams
// engraved on top marking a stack of tilt-out flap fronts.
//
// Width/Depth are the real-world footprint in cm: a hallway shoe cabinet runs
// wide and shallow along a wall, 100 cm wide, 30 cm deep. Height is the real
// carcass height — three tilt-out flaps stacked up to about hip height — shrunk by
// the plan scale like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 30;   // cm
Height = 100;  // cm — three flaps high

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_fronts = true;
// Tilt-out flap fronts, stacked front to back and marked only by the seams
// between them — Front_rows fronts means Front_rows - 1 seams, drawn with
// plain groove() cuts rather than the drawers() symbol: the 30 cm depth
// leaves too little of the top face for that symbol to read at any size once
// it is capped to fit the patch.
Front_rows  = 3;
Seam_w      = 2;  // cm — real-world seam width (0.5 mm printed at 1:40)
Seam_margin = 6;  // cm kept clear at each side of every seam
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
// The 30 cm depth is 7.5 mm across at 1:40 — wide enough for a 4 mm disc.
Magnets = 2;

shoe_cabinet();

module shoe_cabinet() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_fronts)
            for (i = [1 : Front_rows - 1])
                groove(0, -Depth / 2 + i * Depth / Front_rows,
                       Width - 2 * Seam_margin, Seam_w, Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
