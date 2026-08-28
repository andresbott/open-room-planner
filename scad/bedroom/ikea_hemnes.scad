// bedroom / ikea_hemnes — an IKEA HEMNES chest of drawers: its real drawer fronts, two
// knobs on each, on the front (-Y) face of a frame-and-panel carcass on four corner legs
// (legged_block() in lib/common.scad). The size is in the file name, as on the PAX frames.
//
// It used to carry the drawers() pictogram on its top face — the symbol the set uses where
// a piece genuinely cannot show its fronts (see livingroom/tv_unit.scad, whose top is all
// that is left free in front of the TV). A chest of drawers is not that piece: its fronts
// are its whole front, three of them full width, and the token now has them. The symbol is
// a drawing of a chest; this is a chest.
//
// Knobs and not the kitchen's grip rail (see unit_fronts): HEMNES has two round knobs on
// every drawer, and that is what tells a bedroom chest from a fitted run at 1:40.
//
// Width/Depth are the real-world footprint in cm — the HEMNES chests are 108 wide and 50
// deep — and Height the real height of the carcass: 96 for the 3-drawer and the 8-drawer
// chest, 131 for the tall 6-drawer one on the same footprint. All three are shrunk by the
// plan scale (see printed_h() in lib/common.scad), so a chest stands well clear of a bed
// and well short of a wardrobe.

include <../lib/common.scad>

Width  = 108;  // cm
Depth  = 50;   // cm
Height = 96;   // cm — 3-drawer / 8-drawer carcass (131 for the 6-drawer)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm — HEMNES is a heavy solid-pine carcass, so it takes the library's
// cabinet post and a thin top.
Leg      = Leg_w;    // cm — a corner leg
Leg_rail = Leg_set;  // cm the panel between two legs is set back behind them
Slab     = 3;        // cm of the height the top takes
Rail_h   = 5;        // cm of leg left clear under the bottom drawer

Show_drawers = true;
// The fronts: the 3-drawer chest is what 96 cm of carcass carries, one drawer full width.
// The 8-drawer chest is the same footprint with Cols = 2 and Drawers = 4; the tall
// 6-drawer one (Height = 131) is Cols = 2, Drawers = 3.
Drawers = 3;  // courses of fronts up the chest ...
Cols    = 1;  // ... and how many across
Knob_d  = 4;  // cm — a real HEMNES knob
Knobs   = 2;  // per front, as the real chest has

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// piece from pivoting. They go in the panel's own footprint, the broad part of the bottom
// face — 44 cm of it front to back is 11 mm at 1:40, plenty for the 4 mm disc (see
// legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 2;

ikea_hemnes();

module ikea_hemnes() {
    difference() {
        legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
        if (Show_drawers)
            unit_fronts(legged_field_w(Width, Depth, Leg, Leg_rail), Depth,
                        rise(Rail_h),
                        legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail),
                        Cols, Drawers,
                        face_cm = legged_face_d(Width, Depth, Leg_rail),
                        knob_cm = Knob_d, knob_n = Knobs);
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}
