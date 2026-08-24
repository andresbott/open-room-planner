// bedroom / dressing_table — a dressing-table / vanity token: an upright mirror
// standing along the back edge (+Y) of an otherwise bare top.
//
// The top is left FLAT on purpose. A real vanity's drawers are on its front, under
// the top, where a token seen from above cannot show them — recessed fronts cut
// into the top face instead just read as dents in the counter, and the mirror
// already says "dressing table" on its own. So: one clean surface, which is also
// where the bottles and the hairbrush would be.
//
// Width/Depth are the real-world footprint in cm; the Makefile renders the
// common vanity widths (80/100/120) at a slim 40 cm depth. Height is the real
// height of the top — desk height, like a table or a chest of drawers — shrunk by
// the plan scale like the footprint (see printed_h() in lib/common.scad); the
// mirror stands its own real height on top of that.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 40;   // cm
Height = 75;   // cm — the top; the mirror adds Mirror_h above it

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// -- Mirror -------------------------------------------------------------------
// The mirror is a raised board standing on the back of the top, drawn with
// cushion(): a tapered pad that narrows toward the top, so it reads as an
// upright mirror without an unsupported thin vertical wall — the taper prints
// support-free. A shallow oval is cut into its front face for the glass.
Show_mirror  = true;
Mirror_gap   = 2;    // cm kept between the board and the back edge
Mirror_d     = 10;   // cm, board depth (front-to-back) — a slim panel, but still
                     // thick enough at 1:40 (2.5 mm) to stand sturdily
Mirror_margin = 12;  // cm kept clear between the board and each side edge, so
                     // the top shows on either side (where the bottles go)
Mirror_h     = 65;   // cm the board stands above the top face (~140 cm overall)
Mirror_taper = 1;    // printed mm the board pulls in toward the top (draft) — it
                     // is a tall thin panel, so it leans in more than a cushion
// corner rounding of the board — must stay under half the board's printed depth
// (cm(Mirror_d)/2), or footprint_2d()'s inset collapses the panel to nothing
Mirror_r     = Corner_radius;
// The oval "glass", cut into the front (-Y) face of the board.
Glass_w      = 0.62;  // fraction of the board width
Glass_h      = 0.58;  // fraction of the board height
Glass_centre = 0.52;  // height of the oval centre, 0..1 up the board
// printed mm the oval is cut into the front face. The cut starts at the board's
// widest point — its base — and the face leans back by Mirror_taper on the way up,
// so it is sunk that much further to stay this deep at the top of the oval too.
Glass_depth  = 0.7;

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad. The 40 cm
// depth is 10 mm at 1:40 — comfortably wide enough for a 4 mm disc.
Magnets = 2;

dressing_table();

module dressing_table() {
    // the mirror board takes the back Mirror_gap + Mirror_d of the depth
    mirror_w     = Width - 2 * Mirror_margin;
    mirror_y     = Depth / 2 - Mirror_gap - Mirror_d / 2;  // cm, board centre
    mirror_front = Depth / 2 - Mirror_gap - Mirror_d;      // cm, board front edge

    union() {
        // the top: flat, with nothing but the magnet pockets cut into it
        difference() {
            footprint(Width, Depth, Print_h);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        // the mirror board on the back of the top, glass cut into its front face
        if (Show_mirror)
            difference() {
                translate([0, cm(mirror_y), 0])
                    cushion(mirror_w, Mirror_d, Print_h, Mirror_h, Mirror_taper,
                            Mirror_r);
                translate([0, cm(mirror_front) - 0.1,
                           Print_h + rise(Mirror_h) * Glass_centre])
                    rotate([-90, 0, 0])
                        scale([cm(mirror_w) * Glass_w / 2,
                               rise(Mirror_h) * Glass_h / 2, 1])
                            cylinder(h = Glass_depth + Mirror_taper + 0.1, r = 1);
            }
    }
}
