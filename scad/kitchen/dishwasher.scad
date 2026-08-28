// kitchen / dishwasher — an integrated dishwasher: a single tall door panel under a slim
// control fascia, tucked under the run's worktop, on the run's plinth (base_unit() in
// lib/common.scad).
//
// It carries the run's worktop slab like every other counter unit (Slab = Unit_top), so
// it finishes at the same 90 cm and its lip line carries across a row without a step — the
// token is a self-contained length of counter with a dishwasher under it, rather than an
// 82 cm carcass that only lines up once a separate worktop is laid over it. The door runs
// the carcass face up to just under the counter; the fascia at the top is the giveaway.
//
// One panel and a fascia is deliberately the plainest face in the kitchen: it is how
// you tell a dishwasher from an oven (a door under a fascia with knobs on it), from a
// washing machine (a porthole — see appliance_front(), which this one deliberately does
// not use) and from a base cabinet (a grid of drawer fronts).
//
// Width/Depth are the real-world footprint in cm: a standard full-size dishwasher is
// 60x60. Height is the counter height it finishes at — the same 90 cm as the run, with
// the carcass under the counter — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so it comes out level with the worktop either side.
//
// The front is the -Y edge; rotate the piece on the board to face it into the room.

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 60;  // cm
Height = 90;  // cm — counter height, level with the rest of the run

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The worktop slab, real cm — the same slab as the rest of the run (see worktop.scad), so
// the counter and its lip carry across the dishwasher without a step.
Slab = Unit_top;

Show_front = true;
// The control fascia along the top of the door — the one thing that gives an integrated
// dishwasher away above the counter line, so it is what the token is read by.
Fascia = Fascia_h;  // cm of the face it takes

// Magnet pockets in the bottom face (0 = none). Near-square, so one central pocket holds
// it down; it goes in the plinth, as everywhere in the run — 54 cm of it front to back is
// 13.5 mm at 1:40, comfortably wide enough for a 4 mm disc (see unit_plinth_d() and
// Magnet_* in lib/common.scad).
Magnets = 1;

dishwasher();

module dishwasher() {
    z0 = unit_face_z0(Width, Depth, Print_h, Slab);
    z1 = unit_face_z1(Width, Depth, Print_h, Slab);
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_front) {
            unit_fascia(Width, Depth, z1, Fascia, Slab);
            unit_fronts(Width, Depth, z0, z1 - rise(Fascia), 1, 1, Slab);
        }
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}
