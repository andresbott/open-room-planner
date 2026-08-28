// diningroom / sideboard — a dining sideboard / buffet: a frame-and-panel carcass on
// four corner legs (legged_block() in lib/common.scad) under a top slab that stands proud
// all round, with a row of drawers over a row of doors recessed into the panel between
// the legs.
//
// It used to read its whole front elevation off its TOP face — a drawers symbol across
// the back of it and door seams in front, on a piece 45 x 21 mm whose top is the one face
// that cannot show a door. That is the flattened-elevation trick the rest of the set has
// dropped: the fronts are now on the front (-Y) face, where they are in the room, and the
// top is left as the surface a buffet's top actually is.
//
// Everything is a cut or a straight rise, so it prints the right way up with nothing to
// support: legs and posts straight, a 45 deg flare out to the slab, fronts recessed into
// the panel behind the legs.
//
// Width/Depth are the real-world footprint in cm: 180 wide, 45 deep, a standard
// sideboard/buffet size. Height is the real height of the carcass — about hip height,
// like a chest of drawers — shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad).

include <../lib/common.scad>

Width  = 180;  // cm
Depth  = 45;   // cm
Height = 85;   // cm — a buffet stands a touch taller than a table

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm — the library's own proportions for a legged carcass.
Leg      = Leg_w;    // cm — a corner leg, seen on both faces it turns
Leg_rail = Leg_set;  // cm the panel between two legs is set back behind them
Slab     = Leg_top;  // cm of the height the top slab takes

Show_fronts = true;
Drawer_rows = 2;  // courses of fronts up the panel: drawers over doors
Doors       = 3;  // fronts across it — a 180 cm buffet is three bays wide
Rail_h      = 6;  // cm of leg left clear under the bottom front — the bottom rail
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// long, narrow piece from pivoting on the board. They go in the panel's own footprint,
// the broad part of the bottom face — 39 cm of it front to back is 9.75 mm at 1:40,
// plenty for the 4 mm disc (see legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 2;

sideboard();

module sideboard() {
    difference() {
        legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
        // the fronts fill the field of panel between the two legs, from the bottom rail
        // up to the underside of the slab's flare
        if (Show_fronts)
            unit_fronts(legged_field_w(Width, Depth, Leg, Leg_rail), Depth,
                        rise(Rail_h),
                        legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail),
                        Doors, Drawer_rows,
                        face_cm = legged_face_d(Width, Depth, Leg_rail));
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}
