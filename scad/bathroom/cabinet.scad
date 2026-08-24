// bathroom / cabinet — a tall bathroom storage cabinet token: door leaves with
// raised bar handles on the front face, standing on a recessed plinth.
//
// Everything is drawn on the FRONT FACE, which is where a cabinet's doors are and
// the only face of this token with room for them: at 1:40 a 40x35 cabinet is
// 10 x 8.75 mm on the plan but 10 x 45 mm across the front, the biggest face it has.
// The top face is left plain, because a real cabinet's top is a plain panel —
// what tells you which way the token faces, from above as well as by touch, are
// the handles standing proud of the front.
//
// The handles are modelled and not engraved: a handle is the one part of a
// cabinet that sticks out, a 0.4 mm groove says nothing under a fingertip, and a
// half-round bar running up
// the door is a plain vertical prism — it prints off the front face with no
// overhang at all. It leaves the token Handle_d/2 (~0.35 mm, under 1.5 cm real)
// deeper than its footprint at the front, on the side that faces the room.
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
Door_seam_w = 2;    // cm, the gap between two leaves — a face-frame stile
// Real cm — a plinth is a plinth whatever size the cabinet is. It is set back
// across the WHOLE width, corners included: stopped short of them it leaves a
// little foot at each end instead of a plinth.
Plinth_h = 10;   // cm of the front face the plinth takes, set back so it reads as
                 // a plinth and not as a line

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
// How many leaves the front splits into, and how much of its height they take.
function door_count() = Doors > 0 ? Doors
                                 : max(1, round(Width / Door_width));
function door_h() = Print_h - rise(Plinth_h);
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
            footprint(Width, Depth, Print_h);
            if (Show_doors) doors(Print_h);
            if (Magnets > 0) magnets(Width, Depth, Magnets);
        }
        // added last, so nothing cuts into them
        if (Show_handles)
            for (i = [0 : door_count() - 1]) handle(handle_x(i, door_count()));
    }
}

// The front of the cabinet: the plinth set back along the bottom, and a seam
// between every pair of leaves running from the plinth up to the top face.
module doors(top_z, depth = Label_depth) {
    n  = door_count();
    pz = rise(Plinth_h);   // top of the plinth, printed mm
    // overshot past both sides, so the plinth runs right across the front
    front_cut(0, cm(Width) + 1, pz / 2, pz, depth);
    if (n > 1)
        for (i = [1 : n - 1])
            front_cut(leaf_lo(i, n), cm(Door_seam_w),
                      (pz + top_z) / 2 + 0.01, top_z - pz + 0.02,
                      depth);
}

// A handle: a bar running up the door, centred on the front face so half of it is
// buried in the leaf and half stands proud. A vertical prism — every layer lands
// squarely on the one below, so it needs no support. Add it to the solid.
module handle(cx) {
    h = door_h() * Handle_span;
    translate([cx, -cm(Depth) / 2, rise(Plinth_h) + door_h() * Handle_z - h / 2])
        cylinder(h = h, d = Handle_d);
}

// A rectangle cut <depth> mm into the front (-Y) face: <w> x <h> printed mm,
// centred on <cx>,<cz> from the centre of that face's width and the bottom of
// the piece. The counterpart of groove() for the one face that is not the top.
module front_cut(cx, w, cz, h, depth = Label_depth) {
    translate([cx, -cm(Depth) / 2 + (depth - 0.01) / 2, cz])
        cube([w, depth + 0.01, h], center = true);
}
