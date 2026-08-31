// hallway / bench — an entryway shoe bench: a seat on a four-post leg frame
// (legged_block() in lib/common.scad) with a REAL OPEN SHOE SHELF cut into the
// front (-Y) below the seat, and a soft seat pad standing proud of the board.
//
// It used to be the set's plainest labelled brick — a full-height slab with the
// seat pad drawn as a rectangle of groove() on the top face and the shoe shelf as
// a single hairline near the front edge. On a piece 25 x 9 mm on the plan those
// lines said nothing from the side and vanished in a photograph, and what a bench
// IS — somewhere to sit, with your shoes stowed underneath — was nowhere in the
// shape. Now the frame and the shelf are real: from any side you read two posts
// with a rail between them, an open bay (or two, split by a shelf rib) sunk into
// the front where the shoes go, and a cushion proud of the seat board on top. That
// is also what tells it from its hallway neighbours — lower than the console, open
// where the shoe_cabinet is a closed run of tilt-out flaps — and from the set's
// other benches, none of which stow anything under the seat.
//
// The shoe bay is a recess cut into the FRONT face with the shelf left standing
// across it as a rib (front_bays()), not a compartment cut through to a back panel:
// a rib across a shallow bay is a ledge the printer carries, while one across a
// through-cut is a bridge — the trade livingroom/bookshelf.scad makes the other
// way, printing on its back for full-depth shelves. Here the back (+Y) stays flush
// so a bench butts a wall, and everything is a cut or a straight rise with a 45 deg
// flare out to the seat, so it PRINTS THE RIGHT WAY UP with nothing to support. The
// magnet pockets open at the floor, in the rail — the broad part of the bottom face.
//
// In section, across the bench (its front, -Y, on the left):
//
//     |==========|      the cushion, proud of ...
//    |‾‾‾‾‾‾‾‾‾‾‾‾|     ... the seat board, at the full footprint ...
//    /              \    ... a 45 deg flare down to ...
//    |  [========]  |    ... the rail, set back behind the posts, with the shoe
//    |  [--------]  |        bay (a shelf rib splitting two open courses) cut in ...
//    |__|        |__|    ... the corner posts, the only part of the body full width
//
// Width/Depth are the real-world footprint in cm: an entryway bench runs the width
// of a hall (Width) and stays seat-depth (Depth ~ 35 — deep enough to sit on, with
// room for a row of shoes under). Height is the real seat height — a bench sits at
// chair-seat height — shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad), so it comes out one of the lowest pieces of the set.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 35;   // cm
Height = 45;   // cm — seat height, as a dining chair

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm — the library's own proportions for a legged carcass, so
// the bench reads as one set with the sideboard and the dining bench.
Leg      = Leg_w;    // cm — a corner post, seen on both faces it turns
Leg_rail = Leg_set;  // cm the rail (and the shoe bay in it) is set back behind the posts
Seat     = 5;        // cm of the height the seat board takes, standing proud all round

// The shoe shelf, in real cm: an open bay sunk into the front (-Y) rail face, split
// into Shelves + 1 open courses by that many ribs left standing at the face — a low
// bay for shoes with a shelf over it. Set Shelves = 0 for one tall open bay.
Show_shelf  = true;
Shelves     = 1;   // shelf ribs across the bay (so Shelves + 1 open courses)
Cubbies     = 1;   // columns of bays across the width (1 = one shelf the full width)
Shelf_th    = 2;   // cm — a rib, left standing at the face
Shelf_depth = 8;   // cm the bay is sunk into the rail face — kept shallow so each rib
                   // prints as a short ledge and not a bridge (see the header)
Rail_h      = 3;   // cm of rail left under the bottom bay — but floored so the magnet
                   // pocket stays buried under it, never poking into the bay (rail_h())

// A soft seat pad standing proud of the seat board — an upholstered bench. See
// cushion() in lib/common.scad; it self-tapers, so it prints without support. Off
// with -D Show_cushion=false for a plain wooden bench.
Show_cushion = true;
Cushion_rim  = 4;  // cm of seat board left showing round the pad
Cushion_h    = 4;  // cm the pad stands proud of the board

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep
// the long, narrow piece from pivoting on the board. They go in the rail's own
// footprint, the broad part of the bottom face — 29 cm of it front to back is 7.25
// mm at 1:40, wide enough for a 4 mm disc (see legged_floor_w() and Magnet_* in
// lib/common.scad).
Magnets = 2;

// The field of rail between the two posts, the depth to cut into so the bay lands on
// the rail face and not out where the posts are, and the top of that face under the
// seat's flare — the same handoff sideboard.scad makes for its fronts.
function field_w() = legged_field_w(Width, Depth, Leg, Leg_rail);
function face_d()  = legged_face_d(Width, Depth, Leg_rail);
function face_z1() = legged_face_z1(Width, Depth, Print_h, Seat, Leg_rail);

// The base under the bottom bay, in real cm: what Rail_h asks for, but never so low
// that the centred magnet pocket reaches up into the bay — rise_cm(magnet_pad_h())
// is the pocket plus a little cover, in the units the part is written in (as
// laundry/storage_shelving.scad floors its own base) — and never more than half the
// height, so a bay is always left even when the two conflict on a squashed set.
function rail_h() =
    min(Height / 2,
        max(Rail_h, Magnets > 0 ? rise_cm(magnet_pad_h()) : 0));

bench();

module bench() {
    union() {
        difference() {
            legged_block(Width, Depth, Print_h, Leg, Leg_rail, Seat);
            // the shoe bay fills the field of rail between the two posts, from the
            // base up to the underside of the seat's flare
            if (Show_shelf)
                front_bays(field_w(), Depth, rise(rail_h()), face_z1(),
                           rows = Shelves + 1, cols = Cubbies,
                           depth_cm = Shelf_depth, rib_cm = Shelf_th,
                           face_cm = face_d());
            if (Magnets > 0)
                magnets(legged_floor_w(Width, Depth, Leg_rail),
                        legged_floor_d(Width, Depth, Leg_rail), Magnets);
        }
        if (Show_cushion)
            cushion(Width - 2 * Cushion_rim, Depth - 2 * Cushion_rim,
                    Print_h, Cushion_h);
    }
}
