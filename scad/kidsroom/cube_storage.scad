// kidsroom / cube_storage — an open cube-storage shelving grid token
// (KALLAX-style), with the Cols x Rows cube grid engraved on top and
// nothing else.
//
// Width/Depth are the real-world footprint in cm: a 2x2 unit is 77 wide and
// 39 deep — one cube deep, however many columns it runs side by side. Cols
// only drives the engraved grid and should be kept in step with Width by
// hand (see the comment on Width below); Rows only adds more engraved
// divider lines — Depth stays 39 either way, since the unit is always one
// cube deep. Height is the real carcass height, shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad) — a cube is about 39 cm, so keep it
// in step with Rows: 77 for two rows standing up, 147 for four.

include <../lib/common.scad>

Cols   = 2;   // grid columns engraved on top — keep Width in step by hand
Rows   = 2;   // grid rows engraved on top — Depth stays fixed either way
Width  = 77;  // cm — Kallax runs 77 wide for Cols=2 or 147 for Cols=4
Depth  = 39;  // cm — one cube deep
Height = 77;  // cm — Rows cubes high: 77 for Rows=2, 147 for Rows=4

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_grid   = true;
Grid_margin = 2;  // cm the grid sits in from the edge, like bench.scad's Lid_inset
// Magnet pockets in the bottom face (0 = none). Two keep the piece from
// pivoting on the board; see Magnet_* in lib/common.scad. The 39 cm depth is
// 9.75 mm across at 1:40 — comfortably wide enough for a 4 mm disc.
Magnets = 2;

cube_storage();

module cube_storage() {
    difference() {
        footprint(Width, Depth, Print_h);
        // the grid gets the whole top face: Cols x Rows open cube squares
        if (Show_grid) cube_grid(Print_h);
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// The Cols x Rows cube grid: an outer frame plus one interior divider per
// internal column/row boundary, all drawn as groove() edges (like
// bench.scad's lid seam) instead of a filled cut, so it reads as a waffle of
// open cube squares rather than a second footprint.
module cube_grid(top_z, margin = Grid_margin, cols = Cols, rows = Rows) {
    stroke = Symbol_stroke * Scale / 10;  // one nozzle, back-converted to real cm
    hw = Width / 2 - margin;
    hd = Depth / 2 - margin;
    union() {
        // outer frame
        groove(0,   hd, 2 * hw + stroke, stroke, top_z);
        groove(0,  -hd, 2 * hw + stroke, stroke, top_z);
        groove(-hw,  0, stroke, 2 * hd + stroke, top_z);
        groove( hw,  0, stroke, 2 * hd + stroke, top_z);
        // interior column dividers
        for (i = [1 : cols - 1])
            groove(-hw + i * 2 * hw / cols, 0, stroke, 2 * hd + stroke, top_z);
        // interior row dividers
        for (i = [1 : rows - 1])
            groove(0, -hd + i * 2 * hd / rows, 2 * hw + stroke, stroke, top_z);
    }
}
