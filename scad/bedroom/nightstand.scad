// bedroom / nightstand — a bedside table: a bank of drawer fronts, each with its knob, on
// the front (-Y) face of a frame-and-panel carcass standing on four corner legs
// (legged_block() in lib/common.scad), under a clean top.
//
// It used to draw the whole drawer bank on its TOP face — a reveal, seams and knob dimples
// on a piece 10 x 10 mm — which came out reading as holes in a lid rather than as drawers,
// because the top of a bedside table is the one face its drawers are not on. What you now
// see from above is the top, which is where the lamp and the book go, and the drawers are
// where you would open them from.
//
// The knobs are why the fronts are not the kitchen's handleless grip rail (see
// unit_fronts): a bedside chest has knobs, and at 1:40 that is most of what tells a piece
// of bedroom furniture from a fitted one.
//
// Width/Depth are the real-world footprint in cm: bedside tables run 40..60 wide (the
// Makefile builds those), 40 deep. Height is the real top height — a bedside top sits about
// level with the mattress it stands next to — shrunk by the plan scale like the footprint
// (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 40;  // cm
Depth  = 40;  // cm
Height = 55;  // cm — about mattress height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm. A bedside table's legs are slim and its top thin, so it does not
// take the library's cabinet defaults (Leg_* in lib/common.scad).
Leg      = 6;  // cm — a corner leg
Leg_rail = 3;  // cm the rail between two legs is set back behind them
Slab     = 3;  // cm of the height the top takes
Rail_h   = 4;  // cm of leg left clear under the bottom drawer — the bottom rail

Show_drawers = true;
// How many drawer fronts fill the front. Auto by depth — a shallow bedside gets a single
// drawer, a normal-depth one a pair — but override to pin a count.
Drawers = Depth < 32 ? 1 : 2;
// The knobs, in real cm: one per front, or a pair on a top this wide.
Knob_d         = 4;   // cm — a real bedside knob
Knob_pair_from = 55;  // cm of width from which a front gets two of them

// Magnet pockets in the bottom face (0 = none). Small and near-square, so one central
// pocket holds it down. It goes in the rail, the broad part of the bottom face — 34 cm of
// it is 8.5 mm at 1:40, comfortably wide enough for a 4 mm disc (see legged_floor_w() and
// Magnet_* in lib/common.scad).
Magnets = 1;

nightstand();

module nightstand() {
    difference() {
        legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
        if (Show_drawers)
            unit_fronts(legged_field_w(Width, Depth, Leg, Leg_rail), Depth,
                        rise(Rail_h),
                        legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail),
                        1, Drawers,
                        face_cm = legged_face_d(Width, Depth, Leg_rail),
                        knob_cm = Knob_d,
                        knob_n  = Width >= Knob_pair_from ? 2 : 1);
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}
