// kitchen / breakfast_bar — a peninsula with a raised bar: the island's body, stepped on all
// four sides because it stands out in the room, with a bar level standing 15 cm above the
// counter along its BACK edge. bar_stool.scad has been in the set with nothing to sit at;
// this is the thing it sits at.
//
// In section, front (-Y) on the left:
//
//                  |‾‾‾‾|      the bar level, standing on the counter along the back
//     |‾‾‾‾‾‾‾‾‾‾‾‾|    |      the worktop slab, overhanging all round ...
//     |            |    |      ... the carcass, with the fronts on it ...
//      \                |
//      |               |       ... and the plinth, set back all round
//     ---------------------
//
// A TWO-LEVEL TOP is the whole point: from any angle the piece steps up at the back, which no
// other unit in the kitchen does, and that is what separates it from the island it shares a
// body with. The raised level is also what a real breakfast bar is for — it hides the
// worktop's clutter from whoever is sitting on the other side of it.
//
// The bar is on the BACK (+Y), not the front. That is where it is in a room — the cook works
// at the counter on the near side, the stools go on the far side — and it keeps the doors on
// the front (-Y) face where the convention puts them and where a low angle reads them.
//
// WHAT IT DELIBERATELY DOES NOT HAVE is a knee overhang. A real bar cantilevers its worktop
// 30 cm past the carcass for someone's legs, and at 1:40 that is a 7.5 mm step held up by a
// 1 mm slab: either it overhangs far past 45 deg or the printer bridges it, and both come off
// the bed as a droop. A step UP costs nothing — every layer still lands on the one below — so
// the raised level does the talking instead of the cantilever.
//
// Width/Depth are the real-world footprint in cm: 180x90, longer than the island because a
// peninsula has to carry both a run of cabinets and a place to sit. Height is the real
// COUNTER height — the 90 cm the rest of the kitchen finishes at, so the run and the
// peninsula come out level — and Bar_h is what the bar level adds on top of it, the way a
// pillow or a vanity mirror rises above the piece it stands on (see rise() in
// lib/common.scad).
//
// It prints the right way up with nothing to support: the island body's steps are all 45 deg
// flares, the bar is a plain prism rising off the slab, and the magnet pockets open at the
// plinth.

include <../lib/common.scad>

Width  = 180;  // cm
Depth  = 90;   // cm
Height = 90;   // cm — the counter, level with the rest of the kitchen

// the printed height, mm: Height at the plan scale. The bar level stands above this.
Print_h = printed_h(Height);

// The worktop slab, real cm — shared with the rest of the kitchen (see worktop.scad), so the
// peninsula and the run read as one kitchen.
Slab = Unit_top;

Show_bar = true;
// The raised bar level, real cm: how far it stands above the counter and how much of the
// depth it takes along the back edge. 15 cm over a 90 cm counter puts the bar at 105 — the
// standard, and the height bar_stool.scad's 65 cm seat is made for.
Bar_h = 15;  // cm
Bar_d = 30;  // cm

Show_fronts = true;
// The fronts, sized off the width like the run's, so one file covers any length of
// peninsula: one cabinet per Front_unit cm with drawer fronts stacked up each.
Front_unit = 60;  // cm — target width of one cabinet
Front_rows = 2;   // drawer fronts up each one

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep it from
// pivoting; they go in the plinth, which here is set back on every side — 168x78 cm of it,
// 42x19.5 mm at 1:40, so both keep their full wall (see island_plinth_w() and Magnet_* in
// lib/common.scad).
Magnets = 2;

breakfast_bar();

// The bar's depth, clamped so it can never eat more than half the piece — past that there is
// no counter left in front of it and the token is just a taller island.
function bar_d() = min(Bar_d, Depth / 2);
// The worktop slab the bar stands on, printed mm — never nothing, so the two are always one
// solid however the set is squashed.
function bar_base() = max(0.01, unit_slab(Width, Depth, Print_h, Slab));

module breakfast_bar() {
    if (bar_d() < Bar_d)
        echo(str("WARNING: a ", Bar_d, " cm bar leaves no counter in front of it on a ", Depth,
                 " cm peninsula — cut back to ", bar_d(), " cm (give it more: Depth)"));
    if (Show_bar && rise(Bar_h) < Symbol_stroke)
        echo(str("NOTE: a ", Bar_h, " cm bar level is ", rise(Bar_h),
                 " mm at 1:", Scale, " — under one nozzle, so the top reads as one level"));
    cabinets = max(1, round(Width / Front_unit));
    difference() {
        union() {
            island_unit(Width, Depth, Print_h, Slab);
            if (Show_bar) bar();
        }
        if (Show_fronts)
            unit_fronts(Width, Depth,
                        unit_face_z0(Width, Depth, Print_h, Slab),
                        unit_face_z1(Width, Depth, Print_h, Slab),
                        cabinets, Front_rows, Slab);
        if (Magnets > 0)
            magnets(island_plinth_w(Width, Depth), island_plinth_d(Width, Depth), Magnets);
    }
}

// The raised bar level: a strip along the back (+Y) edge, starting inside the worktop slab so
// the two fuse, and rising rise(Bar_h) above it. Its back and its two ends are flush with the
// slab's — the piece butts against a wall or a run at the back like everything else — so the
// only new face is the one looking forward across the counter, which is the step you read.
module bar() {
    bd = bar_d();
    translate([0, cm((Depth - bd) / 2), Print_h - bar_base()])
        linear_extrude(height = bar_base() + rise(Bar_h))
            footprint_2d(Width, bd);
}
