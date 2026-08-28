// bedroom / dressing_table — a dressing-table / vanity: an upright mirror standing along
// the back edge (+Y) of a clean top, over a shallow drawer or two on the front (-Y) face,
// on four corner legs with the knee hole between them (legged_block() in lib/common.scad).
//
// The top is still left FLAT — it is where the bottles and the hairbrush go, and cutting
// fronts into it would only read as dents in the counter. What has changed is that the
// drawers are no longer left off altogether: this file used to argue that "a real vanity's
// drawers are on its front, where a token seen from above cannot show them", which was
// true of a token with nothing but a top face. The front face is now where the rest of the
// set puts its fronts, so that is where these go — a shallow band of them under the top,
// with the leg room a vanity has left plain below.
//
// Width/Depth are the real-world footprint in cm; the Makefile renders the common vanity
// widths (80/100/120) at a slim 40 cm depth. Height is the real height of the top — desk
// height, like a table or a chest of drawers — shrunk by the plan scale like the footprint
// (see printed_h() in lib/common.scad); the mirror stands its own real height on top of
// that.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 40;   // cm
Height = 75;   // cm — the top; the mirror adds Mirror_h above it

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// -- Frame and drawers ---------------------------------------------------------
// The frame, in real cm: slim legs and a thin top, as a vanity has.
Leg      = 6;  // cm — a corner leg
Leg_rail = 3;  // cm the rail between two legs is set back behind them
Slab     = 3;  // cm of the height the top takes

Show_drawers = true;
// One shallow drawer band under the top, with the knee hole left plain below it — which is
// what a dressing table is: you sit at it. Knobs, not the kitchen's grip rail, like the
// rest of the bedroom (see unit_fronts).
Drawers  = 0;   // fronts across the band (0 = one per Drawer_width cm)
Drawer_width = 50;  // cm — nominal width of one front
Knee_h   = 55;  // cm off the floor the drawer band starts — the leg room under it
Knob_d   = 4;   // cm — a real drawer knob
// The knee hole itself, sunk deeper into the front than a drawer front is, so what you
// read between the legs is the space you put your knees in and not another panel. It is
// held clear of the magnet pocket behind it — see knee_depth().
Knee_depth = 4;  // cm
Rail_h     = 5;  // cm of leg left clear under the knee hole — the bottom rail

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

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// piece from pivoting. They go in the rail, the broad part of the bottom face — 34 cm of it
// front to back is 8.5 mm at 1:40, comfortably wide enough for a 4 mm disc (see
// legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 2;

// How many fronts the drawer band carries: as asked for, or one per Drawer_width cm of the
// field between the legs — so an 80 cm vanity gets a single drawer and a 120 cm one a pair.
function drawers() =
    Drawers > 0 ? Drawers
                : max(1, round(legged_field_w(Width, Depth, Leg, Leg_rail) / Drawer_width));

// How deep the knee hole really goes, real cm: what was asked for, but never so deep that
// it breaks into the magnet pocket sitting on the centre line behind it — the pocket keeps
// its full wall, and a table with no magnets gets the depth it asked for.
function knee_depth() =
    Magnets > 0
        ? min(Knee_depth,
              plan_cm(cm(legged_face_d(Width, Depth, Leg_rail)) / 2
                          - magnet_pocket_d() / 2 - Magnet_inset))
        : Knee_depth;

dressing_table();

module dressing_table() {
    // the mirror board takes the back Mirror_gap + Mirror_d of the depth
    mirror_w     = Width - 2 * Mirror_margin;
    mirror_y     = Depth / 2 - Mirror_gap - Mirror_d / 2;  // cm, board centre
    mirror_front = Depth / 2 - Mirror_gap - Mirror_d;      // cm, board front edge

    union() {
        // the carcass: a clean top over the drawer band, on its four legs
        difference() {
            legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
            if (Show_drawers) {
                unit_fronts(legged_field_w(Width, Depth, Leg, Leg_rail), Depth,
                            rise(Knee_h),
                            legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail),
                            drawers(), 1,
                            face_cm = legged_face_d(Width, Depth, Leg_rail),
                            knob_cm = Knob_d);
                // the knee hole under the drawers, sunk deeper than they are
                knee();
            }
            if (Magnets > 0)
                magnets(legged_floor_w(Width, Depth, Leg_rail),
                        legged_floor_d(Width, Depth, Leg_rail), Magnets);
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

// The knee hole: one recess across the field between the legs, from the bottom rail up to
// the drawer band, cut knee_depth() into the front — deeper than a drawer front, so the two
// are told apart by their shadow.
module knee() {
    field = legged_field_w(Width, Depth, Leg, Leg_rail);
    face  = legged_face_d(Width, Depth, Leg_rail);
    z0    = rise(Rail_h);
    z1    = rise(Knee_h);
    if (z1 - z0 > Symbol_stroke && knee_depth() > 0)
        front_recess(0, (z0 + z1) / 2, cm(field) - 2 * cm(Front_gap), z1 - z0,
                     face, cm(knee_depth()));
}
