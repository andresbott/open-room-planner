// livingroom / console — a narrow hall / console table: a top slab standing proud of a
// frame-and-panel body on four corner legs (legged_block() in lib/common.scad), with one
// shallow drawer under the top and the space a console keeps under it sunk deeper still.
//
// It used to be built like the old garden table — a body set back from the edge with corner
// legs — and on a piece only 35 cm deep that came out as a brick: the set-back is clamped by
// what a magnet pocket needs across the base, and its own comment said so ("on a depth this
// shallow that second clamp wins, so by default the body barely sets back at all"). It now
// reads by its frame instead, which is what the rest of the free-standing furniture does.
//
// It is NOT the dining table's slab on four open legs, and the magnet is why: a leg wide enough
// to bury the standard 4 x 2 disc is 25 cm of real furniture at 1:40, and a console is 35 cm
// deep. The frame keeps a 29 cm rail underneath for the pockets, so the piece holds the board
// as hard as everything else — the same trade diningroom/bench.scad makes.
//
// Width/Depth are the real-world top in cm: a hall console typically runs 100-120 cm long and
// only 30-40 cm deep, pushed flat against a wall rather than sat around. Height is the real
// height of the top — a console stands at table height — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad). A small 40x40 side/occasional table is the
// same part at Height = 45 instead: coffee-table height rather than console height.

include <../lib/common.scad>

Width  = 110;  // cm — override to 40 (with Depth 40) for a small side-table variant
Depth  = 35;   // cm
Height = 80;   // cm — top of the slab (45 for a side/coffee table)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm: slim legs and a thin top, as a console has.
Leg      = 6;  // cm — a corner leg
Leg_rail = 3;  // cm the rail between two legs is set back behind them
Slab     = 3;  // cm of the height the top slab takes
Rail_h   = 5;  // cm of leg left clear at the floor — the bottom rail

Show_drawer = true;
// One shallow drawer under the top — a console has at most one course of them — with a knob
// rather than the kitchen's grip rail, like the rest of the free-standing furniture (see
// unit_fronts in lib/common.scad).
Drawers  = 0;   // fronts across the band (0 = one per Drawer_width cm)
Drawer_width = 55;  // cm — nominal width of one front
Drawer_h = 12;  // cm of the face the drawer band takes, measured down from the top
Knob_d   = 4;   // cm — a real drawer knob

Show_open = true;
// The space under the drawer, sunk deeper into the front than a drawer front is, so what you
// read between the legs is the open space a console keeps rather than another panel. Held clear
// of the magnet pocket behind it — see open_depth().
Open_depth = 4;  // cm
Open_gap   = 2;  // cm between the drawer band and the top of it

// Magnet pockets in the bottom face, in a row along the length (0 = none). Two keep the piece
// from pivoting on the board. They go in the rail, the broad part of the bottom face — 29 cm of
// it front to back is 7.25 mm at 1:40, wide enough for a 4 mm disc (see legged_floor_w() and
// Magnet_* in lib/common.scad). The 40x40 side table has room for only ONE, and says so in the
// render log — build that variant with Magnets=1.
Magnets = 2;

// ---- what the face is divided into ------------------------------------------
function field_w() = legged_field_w(Width, Depth, Leg, Leg_rail);
function face_d()  = legged_face_d(Width, Depth, Leg_rail);
function face_z1() = legged_face_z1(Width, Depth, Print_h, Slab, Leg_rail);
// The drawer band hangs off the top of the face; the open space fills what is left above the
// bottom rail. Both clamped into the face, so a squashed set or a side-table height cannot push
// either out through the other.
function drawer_z0() = max(rise(Rail_h), face_z1() - rise(Drawer_h));
function open_z1()   = max(rise(Rail_h), drawer_z0() - rise(Open_gap));
// How many fronts the band carries: as asked for, or one per Drawer_width cm of the field.
function drawers() = Drawers > 0 ? Drawers
                                 : max(1, round(field_w() / Drawer_width));
// How deep the open space really goes, real cm: never so deep that it breaks into the magnet
// pocket sitting on the centre line behind it (as bedroom/dressing_table.scad clamps its knee).
function open_depth() =
    Magnets > 0
        ? min(Open_depth,
              plan_cm(cm(face_d()) / 2 - magnet_pocket_d() / 2 - Magnet_inset))
        : Open_depth;

console();

module console() {
    difference() {
        legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
        if (Show_drawer && face_z1() - drawer_z0() > Symbol_stroke)
            unit_fronts(field_w(), Depth, drawer_z0(), face_z1(), drawers(), 1,
                        face_cm = face_d(), knob_cm = Knob_d);
        if (Show_open && open_z1() - rise(Rail_h) > Symbol_stroke && open_depth() > 0)
            front_recess(0, (rise(Rail_h) + open_z1()) / 2,
                         cm(field_w()) - 2 * cm(Front_gap), open_z1() - rise(Rail_h),
                         face_d(), cm(open_depth()));
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}
