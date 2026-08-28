// diningroom / chair — a dining chair: a dished seat on four corner legs, with a
// framed back panel rising off the back of it. Nothing about it is the task chair
// (office/chair.scad — a five-star base, a column and a wrap-around back): this one is
// a frame, and that is exactly how the two are told apart on the plan.
//
// In section, across the chair:
//
//        |‾‾|          the back panel, its field sunk on BOTH faces so it reads as a
//        |  |          frame round a splat from either side ...
//     ___|__|___       ... the seat slab, dished for real, standing proud all round ...
//    |  |      |  |    ... on the rail, set back behind ...
//    |__|      |__|    ... the four corner legs
//
// It used to be a plain block with a flat pad in front of a raised one — two cushions on
// a brick, and at 11 mm tall the block was most of what you saw. The three things a
// chair is read by are now real: legs at the corners (legged_block() in lib/common.scad),
// a seat you can put a fingertip into, and a back with a frame round it. It still prints
// the right way up with nothing to support: the legs and the back rise straight, the
// flare under the slab is 45 deg, and the dish and the two field recesses are cuts.
//
// No raised seat cushion: a dish and a cushion are two answers to the same question, and
// the dish is the one that reads from directly above, which is how a plan is read. Turn
// Show_dish off and Show_cushion on for an upholstered chair.
//
// Width/Depth are the real-world seat footprint in cm. The heights are real cm too:
// Height is the top of the back — how tall the chair is — and Seat the seat it rises
// from (see printed_h() / rise() in lib/common.scad).

include <../lib/common.scad>

Width  = 45;  // cm
Depth  = 45;  // cm
Height = 90;  // cm — top of the back
Seat   = 45;  // cm — seat height

// the printed height of the seat, mm — the back stands the rest on it
Seat_z = printed_h(Seat);

// The frame, in real cm: a chair's legs are slimmer than a cabinet's posts and its seat
// slab thicker, so it does not take the library's defaults (Leg_* in lib/common.scad).
Leg      = 6;    // cm — a corner leg, seen on both faces it turns
Leg_rail = 2.5;  // cm the rail between two legs is set back behind them
Slab     = 6;    // cm of the height the seat slab takes

Show_dish = true;
// The dish, in real cm — a moulded seat, hollowed for real (see hollow()). It keeps a
// rim all round and stops short of the back panel, so the seat reads as a seat and not
// as a tray. Shallow, and nearly all of it flat floor (Dish_floor, against the library's
// deeper default): a seat you sit on is not a bowl, and a 2 cm dish is already 0.5 mm of
// shadow at 1:40.
Dish_depth = 2;
Dish_floor = 0.85;
Dish_rim   = 5;
Dish_gap   = 2;   // cm left between the dish and the front of the back panel
Dish_r     = 0.8; // printed mm, corner rounding of the dish — softer than the frame

Show_cushion  = false;  // an upholstered seat instead of a dished one
Cushion_rim   = 5;      // cm of seat left showing round it
Cushion_h     = 4;      // cm it stands proud

Show_back = true;
// The back panel, in real cm: narrower than the seat and set in from the rear edge, the
// way a chair's back sits inside its footprint. It rises straight — a vertical wall is
// nothing for the printer, and a taper would eat the thickness the two field recesses
// need — with the field sunk from the front AND the back, leaving a web between them.
Back_w      = 34;
Back_d      = 8;
Back_gap    = 2;
Back_r      = 0.5;  // printed mm — a panel this thin would collapse under Corner_radius
Back_stile  = 5;    // cm of frame left at each side of the sunken field ...
Back_rail_b = 5;    // ... under it, above the seat ...
Back_rail_t = 6;    // ... and over it, at the top of the back
Back_cut    = 0.6;  // mm the field is sunk into each face of the panel

// Magnet pockets in the bottom face (0 = none). One central pocket: the piece is small
// enough that it cannot pivot far. The pocket goes in the rail, which is the broad part
// of the bottom face — 40 cm of it is 10 mm at 1:40, comfortably wide enough for a 4 mm
// disc (see legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 1;

// ---- what fits where --------------------------------------------------------
// The back panel's front face and its centre, real cm from the middle of the seat.
function back_front() = Depth / 2 - Back_gap - Back_d;
function back_cy()    = back_front() + Back_d / 2;
// The dish: the seat less its rim, and less what the back panel and its clearance take
// at the rear — so it is pushed forward, as the part of the seat you actually sit on.
function dish_d()  = max(0, (back_front() - Dish_gap) - (-Depth / 2 + Dish_rim));
function dish_cy() = ((back_front() - Dish_gap) + (-Depth / 2 + Dish_rim)) / 2;
function dish_w()  = max(0, Width - 2 * Dish_rim);
// Corner rounding of the dish, clamped so a small one cannot be rounded away to nothing
// — footprint_2d() erodes by r before it grows back.
function dish_r() = max(0, min(Dish_r, min(cm(dish_w()), cm(dish_d())) / 2 - 0.05));

chair();

module chair() {
    difference() {
        union() {
            legged_block(Width, Depth, Seat_z, Leg, Leg_rail, Slab);
            if (Show_back) back();
            if (Show_cushion)
                translate([0, cm(dish_cy()), 0])
                    cushion(Width - 2 * Cushion_rim, dish_d(), Seat_z, Cushion_h);
        }
        // the dish, sunk into the seat slab
        if (Show_dish && !Show_cushion && dish_w() > 0 && dish_d() > 0)
            translate([0, cm(dish_cy()), 0])
                hollow(Seat_z, rise(Dish_depth), Dish_floor)
                    footprint_2d(dish_w(), dish_d(), dish_r());
        // the field of the back panel, sunk from both faces
        if (Show_back) field();
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}

// The back panel: a straight upright standing on the rear of the seat, from the seat up
// to Height.
module back() {
    translate([0, cm(back_cy()), Seat_z - 0.01])
        linear_extrude(height = rise(Height - Seat) + 0.01)
            footprint_2d(Back_w, Back_d, Back_r);
}

// Its sunken field, cut into both faces of the panel: what is left standing is a stile
// each side, a rail under it and a deeper rail over it — a chair back, from the front and
// from behind. The web between the two cuts is what carries it, so the cuts are kept to
// Back_cut and the panel is never tapered.
module field() {
    fw = cm(Back_w - 2 * Back_stile);
    fh = rise(Height - Seat - Back_rail_b - Back_rail_t);
    cz = Seat_z + rise(Back_rail_b) + fh / 2;
    web = cm(Back_d) - 2 * Back_cut;
    if (fw < Symbol_stroke || fh < Symbol_stroke || web < Symbol_stroke)
        echo(str("WARNING: a ", Back_w, "x", Back_d, " cm back at 1:", Scale,
                 " has no room for a field — left solid"));
    else
        translate([0, cm(back_cy()), 0]) {
            front_recess(0, cz, fw, fh, Back_d, Back_cut);
            back_recess(0, cz, fw, fh, Back_d, Back_cut);
        }
}
