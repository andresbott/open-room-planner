// kitchen / island — a kitchen island: the same slab-over-carcass-over-plinth body as
// a length of worktop run, but stepped on all four sides instead of only at the front,
// because an island stands out in the room and is seen from every side (island_unit()
// in lib/common.scad). Its worktop overhangs all round and its plinth is set back all
// round, which is exactly what tells it from a run against a wall on the plan — that,
// and being 90 cm deep rather than 60.
//
// The fronts go on the front (-Y) face, like every other unit in the set, drawn as a
// row of cabinets with two drawers up each: an island's storage runs side by side along
// its length, it does not stack the way a chest of drawers does.
//
// Width/Depth are the real-world footprint in cm: a 120x90 island, worktop height.
// Height is that real worktop height, shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so the island comes out level with the rest of the
// kitchen run.

include <../lib/common.scad>

Width  = 120;  // cm
Depth  = 90;   // cm
Height = 90;   // cm — standard worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The worktop slab, real cm — shared with the rest of the kitchen (see worktop.scad),
// so an island and a run read as one kitchen.
Slab = Unit_top;

Show_fronts = true;
Front_cols  = 3;  // cabinets along the front face ...
Front_rows  = 2;  // ... and drawer fronts up each one
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// piece from pivoting; they go in the plinth, which here is set back on every side —
// 108x78 cm of it, 27x19.5 mm at 1:40, so both pockets keep their full wall (see
// island_plinth_w() and Magnet_* in lib/common.scad).
Magnets = 2;

island();

module island() {
    difference() {
        island_unit(Width, Depth, Print_h, Slab);
        if (Show_fronts)
            unit_fronts(Width, Depth,
                        unit_face_z0(Width, Depth, Print_h, Slab),
                        unit_face_z1(Width, Depth, Print_h, Slab),
                        Front_cols, Front_rows, Slab);
        if (Magnets > 0)
            magnets(island_plinth_w(Width, Depth), island_plinth_d(Width, Depth),
                    Magnets);
    }
}
