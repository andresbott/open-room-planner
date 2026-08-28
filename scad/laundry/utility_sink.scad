// laundry / utility_sink — a deep single-basin utility sink: a real sunken tub in the worktop
// of a base unit, with a door pair on the carcass face below it.
//
// It used to draw the basin as an outline groove with a tap ring beside it — a 0.4 mm line
// round a bowl that is the whole point of the piece. It is now a hollow, and a deeper one than
// the kitchen's: a utility tub is 30 cm deep where a kitchen bowl is 18, it fills its counter
// almost to the edges, and it has no drainer beside it. Those three things are what tell this
// from kitchen/sink.scad, along with being a 60x50 unit rather than an 80x60 one.
//
// No tap, for the reason washbasin.scad gives: at 1:40 it is a 1 mm pimple that snaps off and
// catches on whatever the piece is stored with. What it would stand on is drawn instead — the
// deck behind the tub is deeper than the lip in front of it, which is also what tells the
// token's back from its front.
//
// Width/Depth are the real-world footprint in cm: 60 x 50 is a common single-basin
// utility/laundry sink size. Height is the real height of the rim — worktop height, so it
// stands a little above the 85 cm machines beside it — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 50;  // cm
Height = 90;  // cm — the rim, at worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The worktop slab, real cm — the same as a kitchen run's, so a utility room and a kitchen
// read as one system (see kitchen/worktop.scad).
Slab = Unit_top;

Show_tub = true;
// The tub, in real cm. Deep, and set close to the edges: a utility sink is a bucket you can
// stand a mop in, not a bowl in a counter.
Tub_depth = 30;  // cm the tub dishes down
Tub_side  = 5;   // cm of deck kept each side of it ...
Tub_front = 5;   // ... in front, where the worktop's lip is ...
Tub_back  = 10;  // ... and behind, where the tap and the splashback go
Tub_r     = 1;   // printed mm, corner rounding of the tub
Tub_floor = 1.2; // printed mm of material kept under the deepest point, over a pocket

// The plughole: a countersunk hole in the flat floor of the tub, the same real 9 cm waste the
// kitchen sink gets — big enough to read as a hole from any angle.
Show_drain = true;
Drain_d    = 9;    // cm across at the tub floor
Drain_h    = 0.5;  // mm it sinks below that floor
Drain_cone = 0.6;  // its bottom as a fraction of its top — the slope catches the light

Show_fronts = true;
Front_cols  = 2;  // door fronts across the unit — a pair under the tub
// Magnet pockets in the bottom face (0 = none). One central pocket holds a piece this size
// down; it goes in the plinth, as everywhere in a run — 44 cm of it front to back is 11 mm at
// 1:40, comfortably wide enough for the 4 mm disc (see unit_plinth_d() and Magnet_* in
// lib/common.scad).
Magnets = 1;

// ---- the tub, sized to the counter it is cut into ---------------------------
function tub_w() = max(0, Width - 2 * Tub_side);
function tub_d() = max(0, Depth - Tub_front - Tub_back);
// Tub centre, real cm from the centre of the counter: forward enough to leave the tap deck
// behind it.
function tub_cy() = Depth / 2 - Tub_back - tub_d() / 2;
// How deep it really dishes, printed mm: what was asked for, less whatever the slab cannot
// give up — a magnet pocket, the floor over it and the plughole sunk into that.
function tub_dz() =
    max(0.5, min(rise(Tub_depth),
                 Print_h - magnet_pocket_h() - Tub_floor - (Show_drain ? Drain_h : 0)));
// Corner rounding, clamped so a small tub cannot be rounded away to nothing.
function tub_r() = max(0, min(Tub_r, min(cm(tub_w()), cm(tub_d())) / 2 - 0.05));
// The plughole: as wide as a real waste, or as wide as the flat floor can take with a wall
// left round it.
function drain_r() = min(cm(Drain_d) / 2,
                         Hollow_floor * min(cm(tub_w()), cm(tub_d())) / 2 - Symbol_stroke);

utility_sink();

module utility_sink() {
    if (Show_tub && tub_dz() < rise(Tub_depth) - 0.001)
        echo(str("WARNING: a ", Tub_depth, " cm tub does not fit in a ", Height,
                 " cm unit over ", magnet_pocket_h(), " mm of magnet pocket — sunk ",
                 rise_cm(tub_dz()), " cm instead (give it more: UTILITY_SINK_H)"));
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_tub) {
            translate([0, cm(tub_cy()), 0])
                hollow(Print_h, tub_dz()) footprint_2d(tub_w(), tub_d(), tub_r());
            if (Show_drain && drain_r() > Symbol_stroke)
                drain();
        }
        if (Show_fronts)
            unit_fronts(Width, Depth,
                        unit_face_z0(Width, Depth, Print_h, Slab),
                        unit_face_z1(Width, Depth, Print_h, Slab),
                        Front_cols, 1, Slab);
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}

// The plughole: a countersunk hole in the middle of the tub's flat floor, sunk Drain_h below
// it and narrowing on the way down. The cut runs a hair above the floor so its rim comes out
// clean — the trick hollow() uses at the top face.
module drain() {
    r = drain_r();
    translate([0, cm(tub_cy()), Print_h - tub_dz() - Drain_h])
        cylinder(h = Drain_h + 0.01, r1 = r * Drain_cone, r2 = r);
}
