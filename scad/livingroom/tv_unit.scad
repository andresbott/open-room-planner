// livingroom / tv_unit — a TV unit / media console: a low, wide frame-and-panel carcass on
// four corner legs (legged_block() in lib/common.scad) carrying an upright TV that stands on
// its back edge, the way the dressing table carries a mirror (see
// bedroom/dressing_table.scad), with a row of fronts on the front (-Y) face below it.
//
// The fronts used to be the drawers() pictogram engraved on the free top in front of the
// screen, on the argument that the top was all the token had left. It is not: the front face
// is where a media unit's doors are and where a low angle can see them, so that is where they
// went, and the top in front of the TV is left as the surface it really is — where a soundbar
// or a console box would sit.
//
// The screen is a raised board drawn with cushion() — a tapered pad that narrows
// toward the top, so it stands as a thin upright panel and still prints support-
// free — with a rectangular recess sunk into its front (-Y) face for the glass. The
// recess is 16:9 and the board is sized around it, so the TV keeps a television's
// proportions whatever the console's width.
//
// Width/Depth are the real-world footprint in cm: media consoles run anywhere from
// a compact 120 cm up to a 200 cm wide wall unit, but stay about 40 cm deep
// throughout, so Width is free while Depth stays put. Height is the real height of
// the carcass — a media unit is low, about seat height, so the TV on it is at eye
// level from the sofa — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad); the TV stands its own real height on top.

include <../lib/common.scad>

Width  = 160;  // cm — 120..200 covers compact to wide wall units
Depth  = 40;   // cm — media consoles stay about this deep at any width
Height = 45;   // cm — a low media console; the TV stands its height above it

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// -- TV ------------------------------------------------------------------------
// The screen board on the back of the top, a screen recessed into its front face.
// Built like the vanity mirror (dressing_table.scad): a cushion() panel, so the
// thin upright board tapers in and prints without an unsupported vertical wall.
Show_tv   = true;
TV_gap    = 2;   // cm kept between the board and the back edge
TV_d      = 8;   // cm, board depth (front-to-back) — a thin panel, but still ~2 mm
                 // at 1:40, so it stands sturdily
TV_margin = 16;  // cm kept clear at each side, so the console top shows beside the
                 // TV (where a soundbar or a console box would sit)
TV_taper  = 0.5; // printed mm the board pulls in toward the top (draft) — gentler
                 // than the mirror's: a TV stands more upright than a leaning mirror
TV_r      = Corner_radius;  // corner rounding of the board, mm — keep < cm(TV_d)/2
// The glass: a 16:9 rectangle recessed into the front (-Y) face inside a thin bezel.
// Its width leads — the height follows 16:9 and the board is sized to leave the
// bezel around it — so the TV reads right at any console width.
Screen_aspect = 16 / 9;  // screen width : height
Screen_wfrac  = 0.90;    // screen width  / board width  (the side bezel)
Screen_hfrac  = 0.80;    // screen height / board height (the top / bottom bezel)
Screen_centre = 0.52;    // height of the screen centre, 0..1 up the board
Screen_depth  = 0.5;     // printed mm the screen is sunk into the front face

// -- Carcass -------------------------------------------------------------------
// The frame, in real cm: slim legs and a thin top, as a low media unit has.
Leg      = 6;  // cm — a corner leg
Leg_rail = 3;  // cm the panel between two legs is set back behind them
Slab     = 3;  // cm of the height the top takes
Rail_h   = 4;  // cm of leg left clear under the bottom front

Show_fronts = true;
Fronts      = 2;  // fronts across the face — a media unit is a bay or two wide
Knob_d      = 4;  // cm — a real knob, as on the rest of the free-standing furniture

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the piece
// from pivoting. They go in the panel's own footprint, the broad part of the bottom face —
// 34 cm of it front to back is 8.5 mm at 1:40, comfortably wide enough for a 4 mm disc (see
// legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 2;

tv_unit();

module tv_unit() {
    // the TV board: its width sets the 16:9 screen, and the screen sets the height
    board_w  = Width - 2 * TV_margin;          // cm
    screen_w = board_w * Screen_wfrac;         // cm
    screen_h = screen_w / Screen_aspect;       // cm
    tv_h     = screen_h / Screen_hfrac;        // cm — board height above the top
    board_y     = Depth / 2 - TV_gap - TV_d / 2;  // cm, board centre
    board_front = Depth / 2 - TV_gap - TV_d;      // cm, board front edge (y)
    // how deep the cut into the front face runs: sunk from the board's widest point
    // (its base) far enough that the taper leaning the face back does not shallow it
    // out at the top — the same allowance the mirror's oval uses.
    cut = Screen_depth + TV_taper + 0.1;

    union() {
        difference() {
            legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
            // a row of fronts on the panel between the legs, where a media unit's doors are
            if (Show_fronts)
                unit_fronts(legged_field_w(Width, Depth, Leg, Leg_rail), Depth,
                            rise(Rail_h),
                            legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail),
                            Fronts, 1,
                            face_cm = legged_face_d(Width, Depth, Leg_rail),
                            knob_cm = Knob_d);
            if (Magnets > 0)
                magnets(legged_floor_w(Width, Depth, Leg_rail),
                        legged_floor_d(Width, Depth, Leg_rail), Magnets);
        }
        // the upright TV, the glass cut into its front (-Y) face
        if (Show_tv)
            difference() {
                translate([0, cm(board_y), 0])
                    cushion(board_w, TV_d, Print_h, tv_h, TV_taper, TV_r);
                translate([0, cm(board_front) - 0.1 + cut / 2,
                           Print_h + rise(tv_h) * Screen_centre])
                    cube([cm(screen_w), cut, rise(screen_h)], center = true);
            }
    }
}
