// hobby / projector_screen — a free-standing projector / projection screen: a big upright
// screen panel on a low, shallow foot. It is the TV unit (livingroom/tv_unit.scad) stripped to
// the one thing that matters here — the screen — and stretched: where the TV sits a modest glass
// on a media console with drawers, this is nearly all screen on a foot just tall enough to bury a
// magnet, the way a pull-down screen on a stand is in a hobby / games room.
//
// The screen is a raised board drawn with cushion() — a tapered pad that narrows toward the top,
// so it stands as a thin upright panel and still prints support-free (the same trick the TV and
// the vanity mirror use) — with a large 16:9 recess sunk into its FRONT (-Y) face for the
// projection surface. The recess width leads and the height follows 16:9, so the screen keeps a
// screen's proportions at either width; a slim bezel is all that stands round it. That recess IS
// the screen icon — a low angle across the table reads the sunken rectangle as a screen, the same
// way it reads the TV's glass, which is why the detail is on the front face and not engraved on
// the top (§1.2).
//
// What it deliberately is NOT: a tripod. A real screen stands on splayed legs or an X foot, which
// at 1:40 is a cage of 1 mm threads that will not print and snaps if it does (§1.3). The token
// gets a low solid foot instead — a plinth wide and deep enough to hold the magnet that keeps a
// tall, light panel from tipping, and no deeper, so the piece stays the thin thing it is.
//
// Width is the real-world screen width in cm — 200 and 280 are the built sizes. Depth is the
// foot's real depth, kept as shallow as a standard 4x2 disc allows (about 26 cm at 1:40) so the
// piece reads as a screen on a stand and not a cabinet. Height is the real height of the FOOT
// only — a low base — shrunk by the plan scale (see printed_h() in lib/common.scad); the screen
// board computes its own height from the width and stands it above the foot.

include <../lib/common.scad>

Width  = 200;  // cm — the screen width (200 and 280 are the built sizes)
Depth  = 26;   // cm — a shallow foot, just deep enough to bury a standard 4x2 disc
Height = 16;   // cm — the FOOT height only; the screen board stands its own height above it

// the printed height, mm: the foot's Height at the plan scale
Print_h = printed_h(Height);

// -- The screen board ----------------------------------------------------------
// A thin upright panel rising off the back of the foot, a 16:9 screen recessed into its front.
Show_screen  = true;
Board_d      = 8;    // cm — board depth (front-to-back): a thin panel, still ~2 mm at 1:40
Board_margin = 8;    // cm kept clear each side of the board (small — the screen is the point)
Board_taper  = 0.5;  // printed mm the board pulls in toward the top (draft), so it prints upright
Board_r      = Corner_radius;  // corner rounding of the board, mm — keep < cm(Board_d)/2
// The screen: a 16:9 rectangle recessed into the front (-Y) face inside a thin bezel. Its width
// leads — the height follows 16:9 and the board is sized to leave the bezel around it — so the
// screen reads right at any width, and it fills nearly the whole board (a projection screen is
// almost all screen, where a TV keeps a wide margin of console beside it).
Screen_aspect = 16 / 9;  // screen width : height
Screen_wfrac  = 0.92;    // screen width  / board width  (a slim side bezel)
Screen_hfrac  = 0.88;    // screen height / board height (a slim top / bottom bezel)
Screen_centre = 0.5;     // height of the screen centre, 0..1 up the board
Screen_depth  = 0.6;     // printed mm the screen is sunk into the front face

// Magnet pockets in the bottom face of the foot, in a row along the width (0 = none). Two keep a
// wide screen from pivoting or tipping; the 26 cm foot is 6.5 mm at 1:40, just wide enough for a
// 4 mm disc (see magnet_min_span() and Magnet_* in lib/common.scad).
Magnets = 2;

projector_screen();

module projector_screen() {
    // the board: its width sets the 16:9 screen, and the screen sets the board's height
    board_w  = Width - 2 * Board_margin;       // cm
    screen_w = board_w * Screen_wfrac;         // cm
    screen_h = screen_w / Screen_aspect;       // cm
    board_h  = screen_h / Screen_hfrac;        // cm — board height above the foot
    board_y     = Depth / 2 - Board_d / 2;     // cm, board centre — at the back, foot in front
    board_front = Depth / 2 - Board_d;         // cm, board front edge (y)
    // how deep the cut into the front face runs: from the board's widest point (its base) far
    // enough that the taper leaning the face back does not shallow it out at the top
    cut = Screen_depth + Board_taper + 0.1;

    union() {
        // the low foot, its magnets in the bottom face
        difference() {
            footprint(Width, Depth, Print_h);
            if (Magnets > 0) magnets(Width, Depth, Magnets);
        }
        // the upright screen board, the 16:9 screen cut into its front (-Y) face
        if (Show_screen)
            difference() {
                translate([0, cm(board_y), 0])
                    cushion(board_w, Board_d, Print_h, board_h, Board_taper, Board_r);
                translate([0, cm(board_front) - 0.1 + cut / 2,
                           Print_h + rise(board_h) * Screen_centre])
                    cube([cm(screen_w), cut, rise(screen_h)], center = true);
            }
    }
}
