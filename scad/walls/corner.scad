// walls / corner — an L: two wall arms meeting at a right angle, so a room is pegged out
// by dropping a corner at each corner and leaving the run between IMPLIED, instead of
// laying a segment along every wall. Same thickness, same 25 mm ribbon height and the same
// square ends as wall.scad, so a corner still butts flush against a straight segment where
// you do want a length of wall — but on its own it is enough to read the turn:
//
//     ##            The outer corner is at -X/-Y (a SW corner); the two arms run out +X
//     ##            and +Y, and the room is the open, concave +X/+Y quarter. A quarter
//     ####          turn in the plan gives the other three corners, the way you turn a
//     ####          wall segment — so one L covers all four and there is no hand to build
//                   (cf. pool.scad, which pegs a pool out of corners exactly the same way).
//
// It carries NO engraved number, unlike wall.scad. A straight segment is picked out of the
// box by the length cut into its face; a corner has no length to carry — its arms are
// STUBS, not a measured wall, and the wall that matters is the one implied in the gap
// between two corners. So the piece is left as pure form: the L silhouette does the work,
// told apart from a straight run by its shape and sized (its thickness) by the ribbon, the
// way the walls tell their own thickness — no ink for something that is not a number.
//
// Thickness is the real wall size in cm (11.5 partition, 17.5/24 load-bearing, as
// wall.scad). Leg is the real cm each arm RUNS OUT PAST the corner block — the visible
// stub, kept the same whatever the thickness so every corner reads as a clean L (a fixed
// OUTER length would shrink to almost a square on the 24 cm wall, whose block alone is
// 24 cm). Each arm is therefore Thickness + Leg long on its outer edge, and the footprint
// is that square. Height is a PRINTED height in mm, not a scaled real one — the
// catalogue's one exception, shared with every wall piece (see the note in wall.scad):
// 25 mm, a real 100 cm at 1:40.
//
// It prints upright without supports: every layer is the same L, nothing overhangs and
// nothing bridges. Each arm takes a magnet like the ribbon it is — one pocket per arm, out
// in the free stub clear of the block, on a low pad where the 11.5 cm partition is too thin
// to bury one (magnet_pads() in lib/common.scad, exactly as wall.scad), the load-bearing
// walls on the small disc as they are.

include <../lib/common.scad>

Thickness = 24;   // cm — 11.5 partition, 17.5/24 load-bearing (as wall.scad)
Leg       = 30;   // cm — the wall run each arm makes PAST the corner block (the visible stub)
Height    = 25;   // PRINTED mm — a real 100 cm at 1:40, as wall.scad (not a scaled 250 cm wall)

// Magnet pockets per arm in the bottom face (0 = none). An arm is a thin ribbon, like a
// straight wall, so the load-bearing walls drop to the small 2x1 disc and the 11.5 cm
// partition — too thin across for even that — gets a low round pad under each pocket
// (magnet_pads() in lib/common.scad; the render log says which pieces are padded). One per
// arm holds the L flat and keeps it from pivoting; along an arm the count is clamped to fit.
Magnets = 1;

corner();

module corner() {
    difference() {
        union() {
            corner_body();
            if (Magnets > 0) arm_pads();
        }
        if (Magnets > 0) arm_magnets();
    }
}

// The two arms as square-ended strips (r = 0, so they butt flush against a straight
// segment), unioned into an L with its outer corner at -X/-Y. Each strip is a full
// footprint side (Thickness + Leg) long and one Thickness deep, seated against its outer
// edge; they overlap in the Thickness x Thickness corner block, which the union merges.
module corner_body() {
    off = arm_off();
    // arm along +X: the -Y strip, full width, seated on the -Y edge
    translate([0, -off, 0]) footprint(Thickness + Leg, Thickness, Height, r = 0);
    // arm along +Y: the -X strip, full depth, seated on the -X edge
    translate([-off, 0, 0]) footprint(Thickness, Thickness + Leg, Height, r = 0);
}

// How far each strip is shifted off centre to seat its outer edge on the footprint edge:
// half the run past the block, in printed mm. (= cm(Thickness + Leg)/2 - cm(Thickness)/2.)
function arm_off() = cm(Leg) / 2;

// One pocket per arm (Magnets each). Each arm's FREE STUB — the Leg x Thickness rectangle
// past the block — is handed to magnets() as its own ribbon, so the disc is sized to the
// wall and the thin partition padded exactly as wall.scad does, and the pocket sits out in
// the stub, clear of the corner block and well away from the other arm's pocket.
module arm_magnets() {
    stub = cm(Thickness) / 2;   // free-stub centre, out from the block along the arm
    off  = arm_off();
    translate([stub, -off, 0]) magnets(Leg, Thickness, Magnets, pad = true);
    translate([-off, stub, 0]) magnets(Thickness, Leg, Magnets, pad = true);
}

// ... and the material a wall too thin to hold a pocket needs under each — nothing on a
// wall thick enough, so the pair is safe at any thickness or scale (as wall.scad). Same
// arguments and placement as arm_magnets(), so the pads land under the pockets.
module arm_pads() {
    stub = cm(Thickness) / 2;
    off  = arm_off();
    translate([stub, -off, 0]) magnet_pads(Leg, Thickness, Magnets);
    translate([-off, stub, 0]) magnet_pads(Thickness, Leg, Magnets);
}
