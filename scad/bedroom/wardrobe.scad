// bedroom / wardrobe — a standalone sliding-door wardrobe: two or three door panels on the
// front (-Y) face, standing on the same plinth the rest of the set's carcasses do
// (base_unit() in lib/common.scad), with a finger pull down the leading edge of each.
//
// The panels sit at TWO DIFFERENT DEPTHS, alternating: that step is what a slider is — one
// leaf runs in front of the next — and it is what tells this piece from a hinged wardrobe or
// a PAX frame at a glance. It replaces the vertical seams this file used to engrave on its
// TOP face: a wardrobe is 59 mm tall and 15 mm deep at 1:40, so its top is the one face the
// doors are not on, and seams drawn there read as saw cuts in a block.
//
// A slider needs no swing, so unlike a door in a wall (walls/door.scad) the piece claims no
// floor beyond its own footprint — push a bed right up to it.
//
// Width/Depth are the real-world footprint in cm: freestanding sliding wardrobes run
// anywhere from a narrow 100 cm up to a 200 cm wide run, 60 cm deep. Height is the real
// carcass height — a full-height sliding wardrobe, the same 236 cm as a tall PAX frame —
// shrunk by the plan scale like the footprint (see printed_h() in lib/common.scad), so it is
// one of the tallest pieces of the set.

include <../lib/common.scad>

Width  = 150;  // cm (100..200)
Depth  = 60;   // cm
Height = 236;  // cm — full-height carcass

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// No worktop: the doors run the full height of the carcass, as a wardrobe's do.
Slab = 0;

Show_doors = true;
// How many leaves share the front: two up to Panel3_from cm of width, three beyond it, so
// no single panel reads unrealistically wide.
Panel3_from = 170;  // cm
Side        = 2;    // cm of carcass left at each end of the run
// The two tracks. Only the BACK-track leaves are cut: the front ones are left at the face,
// so they stand proud of their neighbours by the whole depth of the cut and overlap them at
// the meeting stile — which is what a slider looks like, and something a set of equal
// recesses cannot show (cut two overlapping recesses and the deeper one simply wins).
Track_depth   = 1.2;  // mm the back-track leaves are sunk
Panel_overlap = 6;    // cm the leaf in front laps over the one behind it
// The finger pull down the leading edge of a leaf, in real cm — a slider has no handle to
// stand proud, it has a recessed grip, which is what the token can print (see Grip_h in
// lib/common.scad).
Pull_w     = 5;    // cm across ...
Pull_len   = 45;   // ... how far down the leaf it runs ...
Pull_h     = 120;  // ... and how high off the floor its centre sits
Pull_inset = 5;    // cm in from the leading edge of the leaf
Pull_cut   = 0.5;  // mm it is cut deeper than the leaf around it

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the tall
// piece from pivoting. They go in the plinth — 54 cm of it front to back is 13.5 mm at 1:40,
// plenty for a 4 mm disc (see unit_plinth_d() and Magnet_* in lib/common.scad).
Magnets = 2;

// How many leaves the front carries.
function panels() = Width >= Panel3_from ? 3 : 2;

wardrobe();

module wardrobe() {
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_doors)
            doors(unit_face_z0(Width, Depth, Print_h, Slab),
                  unit_face_z1(Width, Depth, Print_h, Slab));
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}

// The leaves: the run between the two end frames divided <panels()> ways, the even ones left
// at the face on the front track and the odd ones sunk behind them, each lapped over by its
// neighbour and carrying a pull at the edge it is pushed from.
module doors(z0, z1) {
    n    = panels();
    face = unit_face_d(Width, Depth, Slab);
    run  = cm(Width - 2 * Side);
    pw   = run / n;
    ov   = min(cm(Panel_overlap), pw / 3);
    if (pw < Symbol_stroke || z1 - z0 < Symbol_stroke)
        echo(str("WARNING: ", Width, "x", Height, " cm at 1:", Scale,
                 " has no room for ", n, " leaves — left plain"));
    else
        for (i = [0 : n - 1]) {
            // the leaf's own share of the run, and the part of it still showing once the
            // leaves in front have lapped over it
            l0 = -run / 2 + pw * i;
            x0 = l0 + (i > 0 ? ov : 0);
            x1 = l0 + pw - (i < n - 1 ? ov : 0);
            back = i % 2 == 1;
            if (back)
                front_recess((x0 + x1) / 2, (z0 + z1) / 2, x1 - x0, z1 - z0,
                             face, Track_depth);
            // the pull, at the edge this leaf slides away from: the leaves meet in the
            // middle, so the first one is gripped on its right and the next on its left
            pull(back ? x0 + cm(Pull_inset) : x1 - cm(Pull_inset),
                 face, back ? Track_depth : 0, z0, z1);
        }
}

// One finger pull: a slot down the leaf at <x>, sunk <cut> deeper than the leaf it is in and
// clamped into the leaf's own band so it cannot run out through the plinth or the top.
module pull(x, face, relief, z0, z1) {
    len = min(rise(Pull_len), z1 - z0 - 2 * Symbol_margin);
    z   = max(z0 + len / 2 + Symbol_margin, min(z1 - len / 2 - Symbol_margin, rise(Pull_h)));
    if (len > Symbol_stroke)
        front_recess(x, z, cm(Pull_w), len, face, relief + Pull_cut);
}
