// diningroom / display_cabinet — a glazed china cabinet: a solid door pair at the bottom,
// a glazed case of shelves above it, a cornice on top and four corner legs under the lot
// (legged_block() in lib/common.scad).
//
// The glazing is a real recess, not a grid engraved on the top face — which is what this
// used to be: a seam and three lines drawn on a 100 x 40 mm top, standing in for a front
// elevation on the one face that cannot show glass. What reads now is the thing a china
// cabinet is: panes sunk back behind a mullion, with the shelves crossing them as ribs
// left standing at the face. Together with the solid doors under it, that is also what
// tells this piece from the open bookshelf (livingroom/bookshelf.scad, whose
// compartments are cut right through to a back panel) and from a wardrobe.
//
// The panes are cut, not carved out, so a shelf rib's underside is a ledge the depth of
// the glass recess and nothing has to be bridged or supported: it prints the right way up.
//
// Width/Depth are the real-world footprint in cm: a 100 cm-wide, 40 cm-deep cabinet —
// narrower and shallower than a wardrobe, sized to show off china rather than hang
// clothes. Height is the real carcass height — a display cabinet stands about as tall as
// a wardrobe — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad).

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 40;   // cm
Height = 200;  // cm — full-height carcass

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm.
Leg      = Leg_w;    // cm — a corner leg
Leg_rail = Leg_set;  // cm the front is set back behind the legs
Slab     = 5;        // cm of the height the cornice takes — a touch more than a
                     // buffet's top, as a tall cabinet's cornice is
Rail_h   = 6;        // cm of leg left clear under the bottom door — the bottom rail

Show_doors = true;
// The solid part: cupboard doors filling the carcass up to Base_h off the floor, which is
// where a china cabinet stops being a cupboard and starts being a display case.
Base_h = 80;  // cm
Doors  = 2;   // door fronts across it

Show_glass = true;
// The glazed case above, in real cm. The opening is set in from the legs and the cornice
// by a stile and a rail, split down the middle by a mullion, and crossed by Shelves ribs
// left standing at the face — so what you read is panes with shelves behind them.
Glass_gap   = 2;   // cm between the top of the doors and the bottom of the opening
Glass_stile = 4;   // cm of frame at each side of the opening ...
Glass_rail  = 4;   // ... and under the cornice
Mullion     = 4;   // cm of frame where the two glazed doors meet
Shelves     = 3;   // ribs across the panes (so four bays of china)
Shelf_th    = 2;   // cm — a rib, left at the face
Glass_depth = 7;   // cm the panes are sunk back behind the face — deeper than a solid
                   // front's relief, so glass and cupboard door are told apart by how
                   // far back they sit

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// tall piece from pivoting. They go in the front's own footprint, the broad part of the
// bottom face — 34 cm of it is 8.5 mm at 1:40, comfortably wide enough for the 4 mm disc
// (see legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 2;

// ---- where the two halves of the front meet -------------------------------
// The field of front between the two legs, and the depth to cut into so the recesses land
// on it rather than out at the legs.
function field_w() = legged_field_w(Width, Depth, Leg, Leg_rail);
function face_d()  = legged_face_d(Width, Depth, Leg_rail);
// The top of the front, under the cornice and its flare.
function face_z1() = legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail);
// The doors run from the bottom rail up to Base_h; the glazed opening from a gap above
// that to a rail under the cornice. Both clamped into the face, so an odd Base_h or a
// squashed set cannot push either out through the other.
function door_z1()  = max(rise(Rail_h), min(face_z1(), rise(Base_h)));
function glass_z0() = min(face_z1(), door_z1() + rise(Glass_gap));
function glass_z1() = max(glass_z0(), face_z1() - rise(Glass_rail));

display_cabinet();

module display_cabinet() {
    difference() {
        legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
        if (Show_doors)
            unit_fronts(field_w(), Depth, rise(Rail_h), door_z1(), Doors, 1,
                        face_cm = face_d());
        if (Show_glass)
            glazed_case(glass_z0(), glass_z1());
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}

// The glazed case: two columns of panes either side of the mullion, stacked between the shelf
// ribs, each sunk Glass_depth back into the front — front_bays() in lib/common.scad, which is
// the same cut the laundry's open racking and the PAX frame's hanging space are made of. Only
// the depth tells the panes from the solid doors below them.
module glazed_case(z0, z1) {
    front_bays(field_w() - 2 * Glass_stile, Depth, z0, z1,
               rows = Shelves + 1, cols = 2,
               depth_cm = Glass_depth, rib_cm = Shelf_th, mullion_cm = Mullion,
               face_cm = face_d());
}
