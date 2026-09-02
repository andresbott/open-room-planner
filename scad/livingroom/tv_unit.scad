// livingroom / tv_unit — a TV unit / media console: a low, wide cabinet carrying an
// upright TV, with a row of door fronts on the front (-Y) face and a worktop slab on top
// where a soundbar or a console box sits.
//
// PRINTS ON ITS BACK — front face up. The TV is a thin, tall panel, and standing it
// upright on the bed (the way the vanity mirror and the projector screen stand theirs,
// leaned in by a draft taper so they print support-free) is the fragile way to make it: a
// ~2 mm screen board a whole console-height tall wants to peel off the plate. Laid on its
// back instead, the board lies flat, its glass recess opening straight up, and nothing
// thin stands off the bed. For that the whole BACK (+Y) face has to be one flat plane, so:
//   - the carcass is base_unit() — a wall-standing cabinet whose back stays flush (its toe
//     kick and worktop lip are stepped into the FRONT only) — not the open corner legs it
//     used to have: a slim leg laid on its back prints as a bar floating over the plate
//     with its underside unsupported. The legs are given up for the flush back the way the
//     bookshelf gave up its see-through front (livingroom/bookshelf.scad); the toe kick
//     still lifts it off the floor.
//   - the TV board runs back to that same +Y plane with a flat, untapered back, so board
//     and carcass rest on the plate as one surface.
// Front face up, every recess — the door fronts, their knob dimples, the glass — opens
// upward and prints clean, the way the bookshelf's compartments do; the magnet pockets in
// the plinth open sideways, as the bookshelf's do.
//
// The screen is a 16:9 rectangle recessed into the board's front (-Y) face inside a thin
// bezel. Its width leads and the height follows 16:9, with the board sized round it, so
// the TV keeps a television's proportions whatever the console's width; a low angle across
// the table reads the sunken rectangle as a screen (§1.2), which is why it is on the front
// face and not engraved on the top.
//
// Width/Depth are the real-world footprint in cm: media consoles run 120..200 wide but
// stay about 40 cm deep, so Width is free while Depth stays put. Height is the real height
// of the carcass — a media unit is low, about seat height, so the TV on it is at eye level
// from the sofa — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad); the TV stands its own real height on top. +Y is the wall side and
// stays flush, so the unit butts the wall.

include <../lib/common.scad>

Width  = 160;  // cm — 120..200 covers compact to wide wall units
Depth  = 40;   // cm — media consoles stay about this deep at any width
Height = 45;   // cm — a low media console; the TV stands its height above it

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The worktop slab, real cm — how much of the carcass height is the top surface (where a
// soundbar or a console box sits) rather than door front. base_unit() steps its lip into
// the front only, so the back stays flush.
Slab = 4;

// -- TV ------------------------------------------------------------------------
// The screen board stands on the back of the top, its back on the +Y plane — flush with
// the carcass back — so the whole piece prints flat on that face. A plain upright board,
// no draft taper (it does not stand on the bed to print, it lies on its back), with a 16:9
// recess sunk into its front (-Y) face for the glass.
Show_tv   = true;
TV_d      = 8;   // cm, board depth (front-to-back) — a thin panel, but still ~2 mm at
                 // 1:40, so it stands sturdily in use
TV_margin = 16;  // cm kept clear at each side, so the console top shows beside the TV
                 // (where a soundbar or a console box would sit)
TV_r      = Corner_radius;  // corner rounding of the board, mm — keep < cm(TV_d)/2
// The glass: a 16:9 rectangle recessed into the front (-Y) face inside a thin bezel. Its
// width leads — the height follows 16:9 and the board is sized to leave the bezel around
// it — so the TV reads right at any console width.
Screen_aspect = 16 / 9;  // screen width : height
Screen_wfrac  = 0.90;    // screen width  / board width  (the side bezel)
Screen_hfrac  = 0.80;    // screen height / board height (the top / bottom bezel)
Screen_centre = 0.52;    // height of the screen centre, 0..1 up the board
Screen_depth  = 0.5;     // printed mm the screen is sunk into the front face

// -- Fronts --------------------------------------------------------------------
Show_fronts = true;
Fronts      = 2;  // door fronts across the face — a media unit is a bay or two wide
Knob_d      = 4;  // cm — a real knob, as on the rest of the free-standing furniture

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// piece from pivoting. They go in the plinth, the footprint the unit stands on — 34 cm of
// it front to back is 8.5 mm at 1:40, comfortably wide enough for a 4 mm disc (see
// unit_plinth_d() and Magnet_* in lib/common.scad).
Magnets = 2;

tv_unit();

module tv_unit() {
    // the TV board sits on the back of the top: its back edge on the +Y plane (flush with
    // the carcass back), TV_d deep, board_w wide — the width sets the 16:9 screen and the
    // screen sets the board's height
    board_w  = Width - 2 * TV_margin;          // cm
    screen_w = board_w * Screen_wfrac;         // cm
    screen_h = screen_w / Screen_aspect;       // cm
    tv_h     = screen_h / Screen_hfrac;        // cm — board height above the top
    board_y     = Depth / 2 - TV_d / 2;        // cm, board centre — back flush at +Y
    board_front = Depth / 2 - TV_d;            // cm, board front edge (y)
    // the front face is vertical now (no taper), so the glass is a straight cut into it
    cut = Screen_depth + 0.1;

    union() {
        // the carcass: a low cabinet of door fronts, its back left flush (base_unit)
        difference() {
            base_unit(Width, Depth, Print_h, Slab);
            if (Show_fronts)
                unit_fronts(Width, Depth,
                            unit_face_z0(Width, Depth, Print_h, Slab),
                            unit_face_z1(Width, Depth, Print_h, Slab),
                            Fronts, 1, Slab, knob_cm = Knob_d);
            if (Magnets > 0)
                magnets(Width, unit_plinth_d(Width, Depth), Magnets);
        }
        // the upright TV, its back flush with the carcass back, the glass cut into its
        // front (-Y) face
        if (Show_tv)
            difference() {
                translate([0, cm(board_y), Print_h - 0.01])
                    linear_extrude(height = rise(tv_h) + 0.01)
                        footprint_2d(board_w, TV_d, TV_r);
                translate([0, cm(board_front) - 0.1 + cut / 2,
                           Print_h + rise(tv_h) * Screen_centre])
                    cube([cm(screen_w), cut, rise(screen_h)], center = true);
            }
    }
}
