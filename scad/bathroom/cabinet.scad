// bathroom / cabinet — a tall bathroom storage cabinet: recessed door leaves with raised bar
// handles on the front face, standing on the same set-back plinth the rest of the set's
// carcasses do (base_unit() in lib/common.scad).
//
// Everything is on the FRONT FACE, which is where a cabinet's doors are and the only face of
// this token with room for them: at 1:40 a 40x35 cabinet is 10 x 8.75 mm on the plan but
// 10 x 45 mm across the front, the biggest face it has. The top face is left plain, because a
// real cabinet's top is a plain panel — what tells you which way the token faces, from above
// as well as by touch, are the handles standing proud of the front.
//
// The handles are modelled and not engraved, and they are the one place in the set where
// something stands off a face: a handle is the part of a cabinet that sticks out, a 0.4 mm
// groove says nothing under a fingertip, and a half-round bar running up a door is a plain
// VERTICAL PRISM — every layer lands squarely on the one below, so it prints off the front
// face with no overhang at all and nothing thin enough to snap. That is what makes it worth
// it here where a knob or a grip rail (see unit_fronts) does the job everywhere else: it
// leaves the token Handle_d/2 (~0.35 mm, under 1.5 cm real) deeper than its footprint at the
// front, on the side that faces the room.
//
// Width/Depth are the real-world footprint in cm: a slim floor-standing storage
// cabinet, wider than it is deep. Height is the real carcass height — tall bathroom
// storage, up past head height — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 40;   // cm
Depth  = 35;   // cm
Height = 180;  // cm — a tall storage column

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The doors. A leaf is about Door_width cm wide, so a 40 cm cabinet comes out as
// the single door it really has, and a wider one splits into a pair — the count
// is not hard-coded, the same way washbasin.scad derives its fronts.
Show_doors  = true;
Doors       = 0;    // door leaves (0 = auto, see door_count())
Door_width  = 40;   // cm, nominal width of one leaf
// The cabinet has no worktop of its own — the leaves run the full height of the carcass over
// the plinth, as a larder's do (kitchen/cabinet.scad).
Slab = 0;

// The handles: a half-round bar up each leaf, on the edge it opens from. Printed
// mm and fractions — hardware, so it stays the same at any scale.
Show_handles = true;
Handle_d     = 0.7;   // bar diameter; it is centred on the face, so half of it
                      // is buried in the door and half stands proud
Handle_span  = 0.6;   // how much of the door's height the bar runs, as a fraction
Handle_z     = 0.55;  // where its middle sits up the door, likewise
Handle_inset = 1.1;   // in from the leaf's opening edge — enough to clear both
                      // the seam groove and a rounded corner

// Magnet pocket in the bottom face (0 = none). One central pocket is enough to
// stop a piece this small sliding; see Magnet_* in lib/common.scad. A 35 cm-deep
// cabinet is 8.75 mm across at 1:40 — wide enough for the 4 mm disc; anything
// narrower drops to the 2 mm one on its own.
Magnets = 1;

// ---- derived geometry -------------------------------------------------------
// How many leaves the front splits into, and the band of carcass face they fill — from the
// top of the plinth's flare to the top of the piece, since it has no worktop.
function door_count() = Doors > 0 ? Doors
                                 : max(1, round(Width / Door_width));
function door_z0() = unit_face_z0(Width, Depth, Print_h, Slab);
function door_z1() = unit_face_z1(Width, Depth, Print_h, Slab);
function door_h()  = door_z1() - door_z0();
// The x of a leaf's two edges, printed mm from the centre of the piece.
function leaf_lo(i, n) = -cm(Width) / 2 + cm(Width) * i / n;
function leaf_hi(i, n) = -cm(Width) / 2 + cm(Width) * (i + 1) / n;
// Where leaf <i>'s handle goes: on the edge it opens from, which is the edge
// facing the middle of the cabinet — a pair of doors opens outwards from the
// seam between them. A lone door is hinged on the left and opens on the right.
function handle_x(i, n) =
    let (lo = leaf_lo(i, n), hi = leaf_hi(i, n))
    (n == 1 || abs(hi) <= abs(lo)) ? hi - Handle_inset
                                   : lo + Handle_inset;

cabinet();

module cabinet() {
    union() {
        difference() {
            base_unit(Width, Depth, Print_h, Slab);
            // the leaves, recessed into the carcass face; no grip slot cut into them, since
            // this cabinet carries real handles instead
            if (Show_doors)
                unit_fronts(Width, Depth, door_z0(), door_z1(),
                            door_count(), 1, Slab, grip = false);
            if (Magnets > 0)
                magnets(Width, unit_plinth_d(Width, Depth), Magnets);
        }
        // added last, so nothing cuts into them
        if (Show_handles)
            for (i = [0 : door_count() - 1]) handle(handle_x(i, door_count()));
    }
}

// A handle: a bar running up the door, centred on the front face so half of it is
// buried in the leaf and half stands proud. A vertical prism — every layer lands
// squarely on the one below, so it needs no support. Add it to the solid.
module handle(cx) {
    h = door_h() * Handle_span;
    translate([cx, -cm(Depth) / 2, door_z0() + door_h() * Handle_z - h / 2])
        cylinder(h = h, d = Handle_d);
}
