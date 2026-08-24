// kitchen / cabinet — a tall kitchen larder/broom cabinet token, with a door
// seam and handle engraved on top and nothing else. The same body doubles as a
// wall unit hung above a worktop, just shallower.
//
// Width/Depth are the real-world footprint in cm: a 60 cm-wide, 60 cm-deep
// floor-standing larder/broom unit (override Depth to 35 for the 60x35
// wall-unit variant — same width, a shallower carcass). Height is the real carcass
// height — a full-height larder unit, floor to just under the ceiling — shrunk by
// the plan scale like the footprint (see printed_h() in lib/common.scad), so it is
// one of the tallest pieces of the set.

include <../lib/common.scad>

Width  = 60;   // cm
Depth  = 60;   // cm — a 60x35 wall-unit variant shares this width; override to 35 for that
Height = 200;  // cm — full-height larder carcass (220 for the tall run)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_doors = true;
// Door seam: one vertical groove down the middle splits the front into two
// equal doors — 60 cm is a common single-run larder width, so one seam (two
// doors) is enough; a wider run would add a second seam the way
// bedroom/wardrobe.scad does. A short handle stroke sits on the right-hand
// door, next to the seam.
Door_groove_w = 2;   // cm — real-world seam width (0.5 mm printed at 1:40)
Door_margin   = 6;   // cm kept clear at the front/back edge of the seam groove
Handle_gap    = 5;   // cm from the seam to the handle stroke
Handle_len    = 10;  // cm — length of the handle stroke
// Magnet pockets in the bottom face (0 = none). Small and near-square, so one
// central pocket holds it down. At 1:40 the 60 cm footprint is 15 mm across —
// plenty of room for a 4 mm disc (the 35 cm-deep wall-unit variant is only
// 8.75 mm, which the 4 mm disc still fits; anything narrower drops to the
// 2 mm one on its own).
Magnets = 1;

cabinet();

module cabinet() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_doors) {
            // the seam gets the whole depth, less a margin front and back
            groove(0, 0, Door_groove_w, Depth - 2 * Door_margin, Print_h);
            // the handle: a short stroke next to the seam, on the right-hand door
            groove(Door_groove_w / 2 + Handle_gap, 0, Door_groove_w, Handle_len,
                   Print_h);
        }
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
