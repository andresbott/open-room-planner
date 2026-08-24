// diningroom / table — a table token in any of the three standard tops:
// rectangular, square (a rectangle with equal sides) and round.
//
// It is built to LOOK like a table from a low angle without giving up a solid,
// support-free print: a thin top slab at the full footprint, standing on a single
// pedestal that flares out into it — in section
//
//      ______     the top slab, full footprint: the line you read the size off
//      \    /     the flare, at most 45 deg so it prints without support
//       |  |      the pedestal, straight down ...
//       |__|      ... to the floor, where the magnet goes
//
// Only the top slab is full size, so the top stands proud the way a real one does,
// and the space under it is one pedestal instead of legs at the corners. PRINT IT
// FACE DOWN — top face on the bed: upside down the piece only ever narrows as it
// rises, so there is nothing to overhang, the widest face holds it on the bed and
// the magnet pocket opens upwards. The place setting is engraved in the top face,
// which means it prints against the bed.
//
// Width/Depth (or Diameter, for a round top) are the real-world top in cm, and
// Height the real height of that top — dining-table height — shrunk by the plan
// scale like the footprint (see printed_h() in lib/common.scad). A coffee table is
// the same part at Height = 45, with the place setting off.

include <../lib/common.scad>

Round    = false;  // true -> a round top of Diameter; Width/Depth are ignored
Width    = 160;    // cm
Depth    = 90;     // cm
Diameter = 120;    // cm, round tops only
Height   = 75;     // cm — dining-table height (45 for a coffee table)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its
// edge is the line you read the size off.
Top_h = 4;
// How far the pedestal under the top stands in from the edge, in real cm. It is
// what makes the token read as a table rather than a block, so the further in the
// better — but it is clamped below (see table()).
Setback = 35;
// How the body under the slab is split: this share of it flares out into the top,
// the rest is the straight pedestal. The flare has to be at least as tall as the
// set-back is wide to stay inside 45 deg, so it is also what caps the set-back on a
// low piece — give it too little and the pedestal comes out fat.
Flare = 0.5;

Show_setting = true;
// Magnet pockets in the bottom face, in a row along the longer side (0 = none).
// The pockets sit in the foot of the pedestal, which is why the pedestal is never
// set in further than a pocket needs — and why the row is spread over that foot
// rather than the full top; see table() and Magnet_* in lib/common.scad.
Magnets = 2;

table();

module table() {
    // one pair of dimensions for both shapes — a round top is Diameter x Diameter
    w       = Round ? Diameter : Width;
    d       = Round ? Diameter : Depth;
    body_h  = Print_h - rise(Top_h);
    flare_h = body_h * Flare;
    col_h   = body_h - flare_h;
    // The pedestal may not go narrower than a magnet pocket plus its walls — with a
    // hair of slack, so rounding cannot tip the foot under that minimum and drop the
    // piece to the small disc.
    base_min = magnet_min_span(magnet_d_for(w, d)) + 0.1;
    // The set-back is clamped two ways, so one number works on any size and height:
    // it may not lean out more than 45 deg over the height the flare has (flare_h),
    // which is what keeps the slope printable without support, and it must leave a
    // foot wide enough to stand on and to take a magnet pocket.
    back  = max(0, min(cm(Setback), flare_h, (min(cm(w), cm(d)) - base_min) / 2));
    // the patch of top face a symbol may use: on a round top that is the square
    // inscribed in the circle, not the circle's bounding box
    patch = (Round ? cm(Diameter) / sqrt(2) : min(cm(w), cm(d))) - 2 * Symbol_margin;
    difference() {
        union() {
            // the pedestal: the top outline set in by <back>, straight up from the
            // floor (over-long by a hair, so it meets the flare in one solid)
            linear_extrude(height = col_h + 0.01)
                offset(delta = -back) top_2d();
            // the flare: from the pedestal out to the full footprint
            translate([0, 0, col_h])
                hull() {
                    linear_extrude(height = 0.01)
                        offset(delta = -back) top_2d();
                    translate([0, 0, flare_h - 0.01])
                        linear_extrude(height = 0.01) top_2d();
                }
            translate([0, 0, body_h])
                linear_extrude(height = rise(Top_h)) top_2d();
        }
        if (Show_setting)
            place_setting(setting_size(patch, patch), Print_h);
        if (Magnets > 0)
            // The pockets are cut in the BOTTOM face, which is the foot of the
            // pedestal — <back> narrower than the top on every side — so the row is
            // laid out on that foot, not on the top. On the full top the outer
            // pockets would sit right outside the pedestal and break through the
            // flare.
            magnets(w - 2 * plan_cm(back), d - 2 * plan_cm(back), Magnets);
    }
}

// The outline of the top — everything else is built from it.
module top_2d() {
    if (Round) footprint_round_2d(Diameter);
    else       footprint_2d(Width, Depth);
}
