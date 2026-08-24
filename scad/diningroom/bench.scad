// diningroom / bench — a backless dining bench token: a plain low slab with an
// optional shallow seat-pad groove on top, or a raised cushion instead.
//
// Width/Depth are the real-world footprint in cm: a bench pulled up to a dining
// table, seat-depth only (no back). Height is the real seat height — a dining bench
// sits at chair-seat height — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so it comes out one of the lowest pieces of the
// set.

include <../lib/common.scad>

Width  = 140;  // cm
Depth  = 35;   // cm
Height = 45;   // cm — seat height, as a dining chair

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// A shallow groove set in from the edge, hinting at the seat pad. Simple by
// design: a bench is a plain slab, this just marks where you would sit.
Show_groove  = true;
Groove_inset = 4;  // cm, wall left between the groove and the edge

// A raised seat cushion instead of a flat pad — off by default (a bench reads
// fine as a plain slab); flip it on for an upholstered bench. See cushion() in
// lib/common.scad — it self-tapers, so it prints without support.
Show_cushion  = false;
Cushion_inset = 3;  // cm, wall left between the cushion and the edge

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
// The 35 cm depth is 8.75 mm across at 1:40 — wide enough for a 4 mm
// disc.
Magnets = 2;

bench();

module bench() {
    union() {
        difference() {
            footprint(Width, Depth, Print_h);
            if (Show_groove)
                groove(0, 0, Width - 2 * Groove_inset, Depth - 2 * Groove_inset,
                       Print_h);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_cushion)
            cushion(Width - 2 * Cushion_inset, Depth - 2 * Cushion_inset, Print_h);
    }
}
