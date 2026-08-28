// livingroom / sideboard — a low sideboard: a shallow row of drawers over a row of taller
// cupboard doors on the front (-Y) face, on a frame-and-panel carcass with four corner legs
// (legged_block() in lib/common.scad).
//
// The mixed fronts were the right idea in the wrong place. This file used to draw them on its
// TOP face as a flattened elevation — a drawers pictogram across the back half, door seams
// across the front half — on a piece whose top is 40 x 11 mm and whose fronts are all on the
// side you actually look at. They are on that side now, and the split between the two courses
// is uneven (a drawer row is shallower than the cupboard under it), which is what tells this
// from the dining buffet's even grid of bays (diningroom/sideboard.scad).
//
// Width/Depth are the real-world footprint in cm: a 160 cm sideboard, 45 cm deep. Height is
// the real height of the carcass — about hip height, like a chest of drawers — shrunk by the
// plan scale like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 160;  // cm
Depth  = 45;   // cm
Height = 80;   // cm

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm — the library's own proportions for a legged carcass, with a thin top.
Leg      = Leg_w;    // cm — a corner leg
Leg_rail = Leg_set;  // cm the panel between two legs is set back behind them
Slab     = 3;        // cm of the height the top takes
Rail_h   = 5;        // cm of leg left clear under the bottom door

Show_fronts = true;
// Mixed fronts: a shallow band of drawers along the top of the face and taller cupboard doors
// under it. Drawers are shallower than doors on a real sideboard, so the two courses read
// apart by their proportions rather than by a line.
Drawers     = 3;    // drawer fronts across the top band ...
Drawer_share = 0.35; // ... and how much of the face's height that band takes
Doors       = 3;    // cupboard doors across the band below it
Knob_d      = 4;    // cm — a real knob, as on the bedroom chests

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the piece
// from pivoting. They go in the panel's own footprint, the broad part of the bottom face —
// 39 cm of it front to back is 9.75 mm at 1:40, plenty for a 4 mm disc (see legged_floor_w()
// and Magnet_* in lib/common.scad).
Magnets = 2;

// ---- how the face is split --------------------------------------------------
function field_w() = legged_field_w(Width, Depth, Leg, Leg_rail);
function face_d()  = legged_face_d(Width, Depth, Leg_rail);
function face_z1() = legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail);
function face_z0() = rise(Rail_h);
// Where the drawers stop and the doors start, clamped into the face either way.
function split_z() = max(face_z0(),
                         min(face_z1(),
                             face_z1() - (face_z1() - face_z0()) * Drawer_share));

sideboard();

module sideboard() {
    difference() {
        legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
        if (Show_fronts) {
            // the drawer band across the top of the face ...
            unit_fronts(field_w(), Depth, split_z(), face_z1(), Drawers, 1,
                        face_cm = face_d(), knob_cm = Knob_d);
            // ... and the cupboard doors filling everything below it
            unit_fronts(field_w(), Depth, face_z0(), split_z(), Doors, 1,
                        face_cm = face_d(), knob_cm = Knob_d);
        }
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}
