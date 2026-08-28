// kitchen / worktop — a base-cabinet worktop run: a worktop slab overhanging a
// carcass of drawer fronts, the carcass standing on a plinth set back at the floor.
// The body is base_unit() and the fronts unit_fronts(); see the fitted-units section
// of lib/common.scad for the section drawing and why the detail is on the front face.
//
// It used to be a plain slab with two hairlines engraved on its top, and that is the
// one thing a kitchen run cannot be: from above a worktop IS a plain slab — the doors
// are under the overhang — so a token that only carries top-face detail has nothing to
// show. What reads is the silhouette from the side: the lip line under the slab, the
// grid of fronts below it and the toe kick in shadow at the floor.
//
// Width/Depth are the real-world footprint in cm: Depth is the standard 60 cm
// base-cabinet run; Width is modular — override to the standard run lengths 60, 80,
// 100 or 120 (all stay 60 cm deep). Height is the real worktop height — the standard
// 90 cm counter — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad), so every counter-height piece comes out level.
//
// The run's FRONT is the -Y edge; +Y is the wall side and stays flush, so two segments
// butt against each other and against the wall.

include <../lib/common.scad>

Width  = 120;  // cm — modular run length: 60, 80, 100 or 120 (all take Depth=60)
Depth  = 60;   // cm — standard base-cabinet depth
Height = 90;   // cm — standard worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The worktop slab, in real cm — how much of the height is counter rather than
// carcass. Shared with every other unit in the run (Unit_top in lib/common.scad), so
// the lip line carries across a sink or a dishwasher without a step.
Slab = Unit_top;

// Cabinet fronts: a grid on the carcass face, Front_unit cm of run to a cabinet and
// two drawer fronts up each one — which is what a modern run mostly is, and what tells
// this piece from the sink (a door pair under the bowl) and the dishwasher (one full
// front under a fascia) at a glance.
Show_fronts = true;
Front_unit  = 60;  // cm — target width of one cabinet
Front_rows  = 2;   // drawer fronts stacked up each cabinet
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// run from pivoting. They go in the plinth, which is what the piece stands on: 54 cm of
// it front to back is 13.5 mm at 1:40, plenty of room for a 4 mm disc (see Magnet_* in
// lib/common.scad).
Magnets = 2;

worktop();

module worktop() {
    // one cabinet per Front_unit cm, spread evenly so a run that does not divide by it
    // exactly comes out as equal-width cabinets rather than one narrow leftover
    cabinets = max(1, round(Width / Front_unit));
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_fronts)
            unit_fronts(Width, Depth,
                        unit_face_z0(Width, Depth, Print_h, Slab),
                        unit_face_z1(Width, Depth, Print_h, Slab),
                        cabinets, Front_rows, Slab);
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}
