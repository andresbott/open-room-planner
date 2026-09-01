// hobby / weight_bench — the free-weights corner: a padded weight bench with a stack of plates
// beside it. A flat bench on its own is a bench — it would read as the one at the foot of a bed
// or down a dining table — so what marks this one as gym is the STACK OF PLATES next to it: a low
// column of discs with the gaps between them showing, the loaded weight you have set down. The
// bench itself is narrow (a lifting pad, ~34 cm, not a seat you share) on an open leg frame
// (legged_block() in lib/common.scad), which is the other tell.
//
// The barbell is left off on purpose. A bar across a rack at 1:40 is a 1 mm thread spanning open
// air — it will not print and snaps if it does (§1.3) — so the weight is the plates, which have
// real bulk, the same way the multi_gym is its stack and not its cables. The plates are a stack
// of solid discs parted by narrower spacer discs, so every layer lands on the one below (the
// overhang at a spacer is a fraction of a millimetre) and it prints the right way up with nothing
// to support; the bench is a solid leg frame under a tapered seat pad. Magnet pockets go under
// the bench frame — its broad floor.
//
// Width/Depth are the real-world footprint in cm — the bench and the plates side by side, about
// 95 x 130 — and Height the bench's real seat height (~45 cm), shrunk by the plan scale (see
// printed_h() in lib/common.scad); the plate stack stands its own real height beside it.

include <../lib/common.scad>

Width  = 95;   // cm — bench and plate stack side by side
Depth  = 130;  // cm — the bench length
Height = 45;   // cm — the bench (seat) height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// -- The bench ----------------------------------------------------------------
Bench_w   = 34;   // cm — the lifting pad, across (narrow — a bench, not a seat)
Bench_l   = 120;  // cm — its length
Bench_x   = -24;  // cm left of centre the bench sits, leaving the right for the plates
Leg       = 8;    // cm — a corner leg of the frame ...
Leg_rail  = 3;    // ... and how far the rail is set back behind it
Pad       = 6;    // cm — the seat pad standing proud of the frame top

// -- The plate stack ----------------------------------------------------------
Show_plates = true;
Plate_x  = 25;   // cm right of centre the stack sits ...
Plate_y  = 34;   // ... and toward the head end
Plate_d  = 44;   // cm — a weight plate ...
Plate_n  = 4;    // ... how many in the stack ...
Plate_t  = 7;    // ... each this thick (cm) ...
Plate_gap = 3;   // ... parted by a spacer this thick ...
Plate_step = 7;  // ... and this much narrower, so the gap between plates reads

// Magnet pockets in the bottom face (0 = none), in a row along the bench length. They go under
// the bench frame — its broad floor is where the piece really stands (see legged_floor_*() and
// Magnet_* in lib/common.scad). Two keep the long bench from pivoting.
Magnets = 2;

weight_bench();

module weight_bench() {
    union() {
        difference() {
            translate([cm(Bench_x), 0, 0])
                legged_block(Bench_w, Bench_l, Print_h, Leg, Leg_rail);
            if (Magnets > 0)
                translate([cm(Bench_x), 0, 0])
                    magnets(legged_floor_w(Bench_w, Bench_l, Leg_rail),
                            legged_floor_d(Bench_w, Bench_l, Leg_rail), Magnets);
        }
        // the seat pad, on top of the frame
        translate([cm(Bench_x), 0, 0])
            cushion(Bench_w - 4, Bench_l - 8, Print_h, Pad);
        if (Show_plates) plate_stack();
    }
}

// The plate stack: solid discs parted by narrower spacer discs, so the gaps between plates show.
// A plate sits on the spacer below it — a fraction-of-a-mm overhang — so it prints support-free.
module plate_stack() {
    pt = rise(Plate_t);
    gt = rise(Plate_gap);
    translate([cm(Plate_x), cm(Plate_y), 0])
        for (i = [0 : Plate_n - 1]) {
            z = i * (pt + gt);
            translate([0, 0, z]) cylinder(h = pt + 0.01, d = cm(Plate_d));
            if (i < Plate_n - 1)
                translate([0, 0, z + pt])
                    cylinder(h = gt + 0.01, d = cm(Plate_d - Plate_step));
        }
}
