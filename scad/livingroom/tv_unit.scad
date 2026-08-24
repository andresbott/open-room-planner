// livingroom / tv_unit — a TV unit / media console token: a low, wide sideboard
// carrying an upright TV that stands on its back edge, the way the dressing table
// carries a mirror (see bedroom/dressing_table.scad). A row of door / drawer fronts
// is engraved on the free top in front of the screen.
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

Show_fronts = true;
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep
// the piece from pivoting; see Magnet_* in lib/common.scad. A 40 cm depth is 10 mm
// across at 1:40 — comfortably wide enough for a 4 mm disc.
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

    // the fronts sit on the free top in front of the board; with no TV they centre
    tv_take = Show_tv ? TV_gap + TV_d : 0;     // cm of depth the board takes at the back
    front_d = Depth - tv_take;                  // cm left for the fronts symbol
    patch   = min(cm(Width), cm(front_d)) - 2 * Symbol_margin;

    union() {
        difference() {
            footprint(Width, Depth, Print_h);
            // a row of door / drawer fronts on the free top, as big as it allows
            if (Show_fronts)
                translate([0, -cm(tv_take) / 2, 0])
                    drawers(drawers_size(patch, patch), Print_h, rows = 2);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
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
