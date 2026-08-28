// kitchen / sink — a sink base unit: the same body as a length of worktop run, with a
// real sunken bowl in the slab and a door pair on the carcass face below it.
//
// The bowl is a hollow and not an engraved outline, for the reason bathtub.scad gives:
// at 1:40 a 0.4 mm groove says nothing under a fingertip and disappears in a photo
// taken from a low angle, while a bowl 4-5 mm deep reads as a sink from across the
// table. It is cut like the washbasin's — walls sloping out from a small flat floor, so
// nothing overhangs the printer and the plughole has something flat to sit in.
//
// No tap: at 1:40 it is a 1 mm pimple that snaps off and catches on whatever the piece
// is stored with (washbasin.scad leaves its own off for the same reason). What the tap
// would stand on is drawn instead — the deck behind the bowl is deeper than the lip in
// front of it, which is also what tells the token's back from its front.
//
// The fronts are a door PAIR and not the worktop's drawer stack: a sink base cannot
// have drawers, the bowl is in the way, and that is what tells the two apart in the run.
//
// Width/Depth are the real-world cabinet footprint in cm: 80 cm wide, 60 cm deep — the
// standard worktop depth. Height is the real worktop height, shrunk by the plan scale
// like the footprint (see printed_h() in lib/common.scad), so the sink comes out level
// with the rest of the run.

include <../lib/common.scad>

Width  = 80;  // cm
Depth  = 60;  // cm
Height = 90;  // cm — standard worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The worktop slab, real cm — shared with the rest of the run (see worktop.scad).
Slab = Unit_top;

Show_bowl = true;
Bowls     = 1;   // 1 for a single bowl, 2 for a double sink
// The bowl, in real cm. A kitchen bowl is rectangular and deep — 18 cm is a normal
// one — and it sits forward on the deck, so the tap end stays clear behind it.
Bowl_depth = 18;  // cm the bowl dishes down
Bowl_side  = 9;   // cm of deck kept each side of it ...
Bowl_front = 8;   // ... in front, where the worktop's lip is ...
Bowl_back  = 14;  // ... and behind, where the tap and the splashback go
Bowl_w_max = 50;  // cm — a wide unit gets a big bowl, not a trough
Bowl_w_min = 20;  // ... and a narrow one still gets a bowl
Bowl_d_min = 16;
Bowl_r     = 1;    // printed mm, corner rounding of the bowl — softer than the carcass
Bowl_floor = 1.2;  // printed mm of material kept under the deepest point, over a pocket

// The plughole: a countersunk hole in the flat floor of each bowl. A real kitchen waste
// is 9 cm across, which is 2.25 mm at 1:40 — big enough to read as a hole from any
// angle, unlike the engraved ring a bath gets (bathtub.scad), whose basin is ten times
// the area. It widens upwards, so it prints like the bowl it sits in.
Show_drain = true;
Drain_d    = 9;    // cm across at the bowl floor
Drain_h    = 0.5;  // mm it sinks below that floor
Drain_cone = 0.6;  // its bottom as a fraction of its top — the slope catches the light

Show_fronts = true;
Front_cols  = 2;  // door fronts across the unit — a pair under the bowl
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// piece from pivoting; they go in the plinth, as everywhere in the run (see
// unit_plinth_d() and Magnet_* in lib/common.scad).
Magnets = 2;

// ---- the bowl, sized to the counter it is cut into --------------------------
function per_width() = Width / Bowls;
function bowl_w() = max(Bowl_w_min, min(Bowl_w_max, per_width() - 2 * Bowl_side));
function bowl_d() = max(Bowl_d_min, Depth - Bowl_front - Bowl_back);
// Bowl centre, real cm from the centre of the counter: forward enough to leave the tap
// deck behind it, and spread evenly across the width for a double sink.
function bowl_cy()  = Depth / 2 - Bowl_back - bowl_d() / 2;
function bowl_cx(i) = -Width / 2 + per_width() * (i + 0.5);
// How deep it really dishes, printed mm: what was asked for, less whatever the slab
// cannot give up — a magnet pocket, the floor over it and the plughole sunk into that.
function bowl_dz() =
    max(0.5, min(rise(Bowl_depth),
                 Print_h - magnet_pocket_h() - Bowl_floor
                         - (Show_drain ? Drain_h : 0)));
// The bowl's corner rounding, clamped so a small bowl cannot be rounded away to
// nothing: footprint_2d() erodes by r before it grows back.
function bowl_r() = max(0, min(Bowl_r,
                               min(cm(bowl_w()), cm(bowl_d())) / 2 - 0.05));
// The plughole, printed mm: as wide as a real waste, or as wide as the flat floor of
// the bowl can take with a wall left round it.
function drain_r() = min(cm(Drain_d) / 2,
                         Hollow_floor * min(cm(bowl_w()), cm(bowl_d())) / 2
                             - Symbol_stroke);

sink();

module sink() {
    if (Show_bowl && bowl_dz() < rise(Bowl_depth) - 0.001)
        echo(str("WARNING: an ", Bowl_depth, " cm bowl does not fit in a ", Height,
                 " cm unit over ", magnet_pocket_h(), " mm of magnet pocket — sunk ",
                 rise_cm(bowl_dz()), " cm instead (give it more: SINK_H)"));
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_bowl)
            for (i = [0 : Bowls - 1]) {
                bowl(bowl_cx(i), bowl_cy());
                if (Show_drain && drain_r() > Symbol_stroke)
                    drain(bowl_cx(i), bowl_cy());
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

// One bowl, sunk into the worktop slab at <cx>,<cy> real cm from the centre of it.
module bowl(cx, cy) {
    translate([cm(cx), cm(cy), 0])
        hollow(Print_h, bowl_dz())
            footprint_2d(bowl_w(), bowl_d(), bowl_r());
}

// The plughole: a countersunk hole in the middle of a bowl's flat floor, sunk Drain_h
// below it and narrowing on the way down. The cut runs a hair above the floor so its
// rim comes out clean, the trick hollow() uses at the top face.
module drain(cx, cy) {
    r = drain_r();
    translate([cm(cx), cm(cy), Print_h - bowl_dz() - Drain_h])
        cylinder(h = Drain_h + 0.01, r1 = r * Drain_cone, r2 = r);
}
