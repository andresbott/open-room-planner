// kitchen / cabinet — a tall larder / broom unit: full-height door fronts on the front
// (-Y) face, standing on the same plinth as the rest of the kitchen (base_unit() in
// lib/common.scad). The same body doubles as a wall unit hung above a worktop, just
// shallower.
//
// The doors used to be a seam and a handle engraved on the top face — on a piece that is
// 50 mm tall and 15 mm square at 1:40, so the one face they could not be read from. They
// are now on the face they are on in the room, as a grid of recessed fronts: a pair
// stacked up the unit, which is what a full-height larder carries and what tells it from
// a fridge (one tall door over a short freezer one) standing next to it.
//
// It has no worktop slab of its own (Slab = 0): a larder is doors floor to ceiling.
//
// Width/Depth are the real-world footprint in cm: a 60 cm-wide, 60 cm-deep
// floor-standing larder/broom unit (override Depth to 35 for the 60x35 wall-unit variant
// — same width, a shallower carcass). Height is the real carcass height — a full-height
// larder unit, floor to just under the ceiling — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad), so it is one of the tallest pieces of
// the set.

include <../lib/common.scad>

Width  = 60;   // cm
Depth  = 60;   // cm — a 60x35 wall-unit variant shares this width; override to 35 for that
Height = 200;  // cm — full-height larder carcass (220 for the tall run)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// No worktop: a larder unit's fronts run the full height (see above).
Slab = 0;

Show_doors = true;
// The fronts, derived from the carcass so one file covers a 60 cm larder, a wide run and
// a shallow wall unit: one door per Door_width cm of width, and one course of doors per
// Door_height cm of height — so a full-height 200 cm unit comes out as the three courses
// a real larder is built from (a top door, a middle door and a drawer under them) and a
// 60 cm wall unit as the single door it is. Three courses is also what tells the larder
// from the fridge beside it, which is two and splits them nowhere near evenly.
Door_width  = 60;  // cm — nominal width of one door front
Door_height = 70;  // cm — ... and how tall one course of them runs

// Magnet pockets in the bottom face (0 = none). Small and near-square, so one central
// pocket holds it down. It goes in the plinth: 54 cm of that front to back is 13.5 mm at
// 1:40, plenty for a 4 mm disc, and the 35 cm-deep wall-unit variant still leaves 29 cm
// (7.25 mm), which the 4 mm disc also fits (see unit_plinth_d() and Magnet_* in
// lib/common.scad).
Magnets = 1;

cabinet();

module cabinet() {
    z0   = unit_face_z0(Width, Depth, Print_h, Slab);
    z1   = unit_face_z1(Width, Depth, Print_h, Slab);
    cols = max(1, round(Width / Door_width));
    rows = max(1, round(Height / Door_height));
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_doors)
            unit_fronts(Width, Depth, z0, z1, cols, rows, Slab);
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}
