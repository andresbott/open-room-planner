// diningroom / bench — a backless dining bench: a dished seat slab on four corner legs,
// the same frame and the same seat as diningroom/chair.scad without the back, so a bench
// and the chairs round the table read as one set.
//
// It used to be a plain slab with a rectangle engraved on top — a 35 x 3.5 mm brick with
// a 0.4 mm line on it, which said nothing from the side and almost nothing from above.
// The legs (legged_block() in lib/common.scad) and the seats (hollow()) are real now, so
// it reads as seating from any angle, and the piece still prints the right way up with
// nothing to support: the legs rise straight, the flare under the slab is 45 deg, and
// the dishes are cuts whose walls slope out.
//
// It is a frame and not a slab on four open legs the way the table is, and the magnet is
// why: a leg wide enough to bury the standard 4 x 2 disc is 25 cm of real furniture at
// 1:40, which is most of a bench's 35 cm depth. The frame keeps a 27 cm rail underneath
// for the pockets to go in, so the bench holds onto the board as hard as everything else
// does — and it matches the chairs round the table, which cannot print face down at all
// (their backs are on the other side of the seat).
//
// Width/Depth are the real-world footprint in cm: a bench pulled up to a dining table,
// seat-depth only (no back). Height is the real seat height — a dining bench sits at
// chair-seat height — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad), so it comes out one of the lowest pieces of the set.

include <../lib/common.scad>

Width  = 140;  // cm
Depth  = 35;   // cm
Height = 45;   // cm — seat height, as a dining chair

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The frame, in real cm — the chair's leg, so the two read as a set across a table, with
// the rail set back a little further: the piece is four times as long, so it takes a
// deeper shadow to carry the same weight.
Leg      = 6;    // cm — a corner leg
Leg_rail = 4;    // cm the rail between two legs is set back behind them
Slab     = 5;    // cm of the height the seat slab takes

Show_dish = true;
// The seat, in real cm: ONE DISH PER PLACE rather than one running the length of the
// bench. A single long hollow in a piece 8.75 mm deep and 11.25 mm tall reads as a trough
// — the body under it is taller than the seat is wide — while a row of dishes reads as
// seating and says how many people the bench takes. Each is the chair's dish, shallow and
// nearly all flat floor (a seat is not a bowl).
Seats      = 0;   // 0 = one place per Seat_pitch cm of width
Seat_pitch = 45;  // cm — the width of a place on a bench
Dish_depth = 2;
Dish_floor = 0.85;
Dish_gap   = 4;   // cm of slab left between two dishes ...
Dish_rim   = 5;   // ... and in front of and behind them
Dish_r     = 0.8; // printed mm, corner rounding of a dish

// A raised cushion instead of the dish — for an upholstered bench. See cushion() in
// lib/common.scad; it self-tapers, so it prints without support.
Show_cushion  = false;
Cushion_rim   = 3;  // cm of slab left showing round it
Cushion_h     = 4;  // cm it stands proud

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// long, narrow piece from pivoting on the board. They go in the rail, which is the broad
// part of the bottom face — 29 cm of it front to back is 7.25 mm at 1:40, wide enough for
// a 4 mm disc (see legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 2;

// How many places the bench has, and what each one gets of the width.
function seats()    = Seats > 0 ? Seats : max(1, round(Width / Seat_pitch));
function share()    = Width / seats();
function dish_cx(i) = -Width / 2 + share() * (i + 0.5);
function dish_w()   = max(0, share() - 2 * Dish_gap);
function dish_d()   = max(0, Depth - 2 * Dish_rim);
// Clamped so a shallow bench cannot have a dish rounded away to nothing.
function dish_r() = max(0, min(Dish_r, min(cm(dish_w()), cm(dish_d())) / 2 - 0.05));

bench();

module bench() {
    difference() {
        union() {
            legged_block(Width, Depth, Print_h, Leg, Leg_rail, Slab);
            if (Show_cushion)
                cushion(Width - 2 * Cushion_rim, Depth - 2 * Cushion_rim,
                        Print_h, Cushion_h);
        }
        if (Show_dish && !Show_cushion && dish_w() > 0 && dish_d() > 0)
            for (i = [0 : seats() - 1])
                translate([cm(dish_cx(i)), 0, 0])
                    hollow(Print_h, rise(Dish_depth), Dish_floor)
                        footprint_2d(dish_w(), dish_d(), dish_r());
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}
