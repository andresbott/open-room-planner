// kitchen / fridge — a freestanding fridge-freezer: two door panels on the front (-Y)
// face, the fridge over the freezer, each recessed inside its own shadow gap with a grip
// rail along its top, standing on the same plinth as the rest of the kitchen
// (base_unit() in lib/common.scad).
//
// The doors used to be engraved on the TOP face, with +Y standing in for "up" — a
// flattened elevation drawn on the one face that cannot show it. A fridge is a 46 mm
// tall block at 1:40 and its whole story is on the front: the split between the two
// doors, and how much lower the freezer's is. That is now where it is, and it reads from
// across the table instead of needing to be picked up and puzzled over.
//
// It has no worktop slab (Slab = 0) — a fridge's own top is its top — so the panels run
// the full height of the case.
//
// Width/Depth are the real-world footprint in cm: a fridge-freezer combi runs close to
// square, about 60x60 (an American-style side-by-side is much bigger — try Width = 90,
// Depth = 70). Height is the real case height — a tall freestanding combi — shrunk by
// the plan scale like the footprint (see printed_h() in lib/common.scad), so it stands
// with the larder units and the wardrobes.

include <../lib/common.scad>

Width  = 60;   // cm — American-style side-by-side: Width = 90, Depth = 70
Depth  = 60;   // cm
Height = 185;  // cm — a tall freestanding fridge-freezer

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// No worktop: a fridge's doors run the full height of the case (see above).
Slab = 0;

Show_doors = true;
// Where the two doors meet, in real cm off the floor — a bottom-freezer combi keeps the
// freezer to roughly a third of the case, so this is the height of the freezer's own
// front. Set it to 0 for a single-door fridge with no freezer at all.
Freezer_h = 60;  // cm
// Door fronts side by side per door, for a case wide enough to have them: an American
// side-by-side is a pair (Doors = 2), a 60 cm combi one leaf each.
Doors = 1;

// Magnet pockets in the bottom face (0 = none). The footprint is near-square, so one
// central pocket is enough to stop it pivoting; it goes in the plinth — 54 cm of it front
// to back is 13.5 mm at 1:40, comfortably wide enough for the 4 mm disc (see
// unit_plinth_d() and Magnet_* in lib/common.scad).
Magnets = 1;

fridge();

module fridge() {
    z0    = unit_face_z0(Width, Depth, Print_h, Slab);
    z1    = unit_face_z1(Width, Depth, Print_h, Slab);
    // the seam between the two doors, clamped into the face so a squashed set or an odd
    // Freezer_h cannot put it out through the top of the case or down into the plinth
    split = max(z0, min(z1, rise(Freezer_h)));
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_doors) {
            // the freezer's front, and the fridge's filling everything above it — two
            // calls at two bands, because the split is nowhere near half way
            if (split > z0) unit_fronts(Width, Depth, z0, split, Doors, 1, Slab);
            unit_fronts(Width, Depth, split, z1, Doors, 1, Slab);
        }
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}
