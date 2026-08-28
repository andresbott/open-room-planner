// diningroom / table — a table token in any of the three standard tops: rectangular,
// square (a rectangle with equal sides) and round.
//
// A table is read by the air under its top, so this is one of the two parts in the set
// that gets real air rather than a recess (office/desk.scad is the other), and it gets it
// the same way: PRINT IT FACE DOWN — top face on the bed. Upside down the piece only ever
// rises from the widest face, so there is nothing to overhang and nothing to bridge
// between the legs, and the magnet pockets open upwards for the discs to drop into. The
// place setting is engraved in the top face, which means it prints against the bed.
//
// A rectangular or square top stands on FOUR CORNER LEGS, which is what a dining table
// has and what tells this piece from the desk on its two panel ends — in section, across
// the width:
//
//      ________________     the top slab, at the full footprint: the line you read the
//     |_|            |_|    size off, standing proud of the legs all round ...
//       |            |      ... a leg at each corner, straight down to the floor,
//       |            |          with the magnet pocket in the foot
//
// A round top keeps the single PEDESTAL a round table really has, flaring out into the
// top at no more than 45 deg (Legs = false does the same for a rectangular one):
//
//      ______     the top slab, full footprint
//      \    /     the flare, at most 45 deg so it prints without support
//       |  |      the pedestal, straight down ...
//       |__|      ... to the floor, where the magnet goes
//
// Width/Depth (or Diameter, for a round top) are the real-world top in cm, and Height the
// real height of that top — dining-table height — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad). A coffee table is the same part at
// Height = 45, with the place setting off.

include <../lib/common.scad>

Round    = false;  // true -> a round top of Diameter; Width/Depth are ignored
Width    = 160;    // cm
Depth    = 90;     // cm
Diameter = 120;    // cm, round tops only
Height   = 75;     // cm — dining-table height (45 for a coffee table)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its edge is
// the line you read the size off.
Top_h = 4;

// -- four corner legs (a rectangular or square top) ---------------------------
// false -> the pedestal below instead. A round top always takes the pedestal: four
// corner legs need corners.
Legs = true;
// A leg, in real cm. A real dining-table leg is about 7 cm, which is 1.75 mm at 1:40 and
// nothing a magnet could live in, so the token's is as wide as the pocket in its foot
// needs — clamped up to that in leg_w(), the same allowance office/desk.scad makes for
// its panel ends.
Leg       = 12;
Leg_inset = 2;   // cm the legs are set in from the edges, so the top stands proud
Gap_min   = 20;  // cm of clear span that must be left between two legs

// -- one central pedestal (a round top, or Legs = false) ----------------------
// How far the pedestal under the top stands in from the edge, in real cm. It is what
// makes the token read as a table rather than a block, so the further in the better —
// but it is clamped below (see back()).
Setback = 35;
// How the body under the slab is split: this share of it flares out into the top, the
// rest is the straight pedestal. The flare has to be at least as tall as the set-back is
// wide to stay inside 45 deg, so it is also what caps the set-back on a low piece — give
// it too little and the pedestal comes out fat.
Flare = 0.5;
// The foot the pedestal stands on, in real cm — a pedestal table has one, and without it
// the token comes out as a mushroom on a stick. It spreads Foot_out beyond the column and
// narrows back into it over Foot_cone, which is a step INWARDS on the way up and so
// prints at any slope. It is also the face the magnet pocket goes in, and it is always
// wider than the column, so the pocket has more wall round it than it did before.
Foot_out  = 12;  // cm the foot spreads past the column (0 = none — a plain stem)
Foot_h    = 4;   // cm of it that is straight, at the floor ...
Foot_cone = 8;   // ... and how tall the cone back in to the column is

Show_setting = true;
// Magnet pockets in the bottom face (0 = none). On a legged top that is one per FOOT, in
// diagonal order, so two of them cannot let the piece pivot; four is one in every foot.
// On a pedestal they are a row in its foot — which is why the pedestal is never set in
// further than a pocket needs. See leg_magnets() / pedestal_magnets() and Magnet_* in
// lib/common.scad.
Magnets = 2;

// ---- how wide a leg really comes out ----------------------------------------
// A leg, and the clear span it leaves — both from the shared slab-on-legs clamps in
// lib/common.scad, which put a magnet pocket's own minimum first. A table with no magnets
// asks nothing of its legs.
function min_span_cm() = Magnets > 0 ? magnet_span_cm() : 0;
function leg_w()   = slab_leg(Width, Depth, Leg, min_span_cm(), Leg_inset, Gap_min);
function leg_gap() = slab_leg_gap(Width, Depth, leg_w(), Leg_inset);
// True when the top is one that can carry corner legs.
function legged() = Legs && !Round;

table();

module table() {
    // one pair of dimensions for both shapes — a round top is Diameter x Diameter
    w     = Round ? Diameter : Width;
    d     = Round ? Diameter : Depth;
    // the patch of top face a symbol may use: on a round top that is the square
    // inscribed in the circle, not the circle's bounding box
    patch = (Round ? cm(Diameter) / sqrt(2) : min(cm(w), cm(d))) - 2 * Symbol_margin;
    if (legged() && leg_gap() < Gap_min - 0.001)
        echo(str("NOTE: a ", Width, "x", Depth, " cm top at 1:", Scale, " leaves ",
                 leg_gap(), " cm between legs a magnet fits in, under the ", Gap_min,
                 " cm asked for — a pedestal reads better this small (Legs=false)"));
    difference() {
        if (legged()) legs_body();
        else          pedestal(w, d);
        if (Show_setting)
            place_setting(setting_size(patch, patch), Print_h);
        if (Magnets > 0) {
            if (legged())
                slab_leg_pockets(Width, Depth, leg_w(), Magnets, inset_cm = Leg_inset);
            else          pedestal_magnets(w, d);
        }
    }
}

// The legged body: the top slab at the full footprint with a leg standing under each corner,
// set in far enough that the slab is proud of them on both faces they turn — slab_on_legs()
// in lib/common.scad, which is the same body the garden table and the hall console stand on.
module legs_body() {
    slab_on_legs(Width, Depth, Print_h, leg_w(), Top_h, inset_cm = Leg_inset) top_2d();
}

// The pedestal body: a foot at the floor, a cone in to the column, the column straight up
// and a flare back out to the full footprint under the slab.
module pedestal(w, d) {
    slab    = min(rise(Top_h), Print_h / 2);
    body_h  = Print_h - slab;
    flare_h = body_h * Flare;
    back    = back(w, d, flare_h);
    foot    = foot_back(w, d, flare_h);
    // what the foot and its cone may take of the space under the flare
    fh      = min(rise(Foot_h), (body_h - flare_h) / 3);
    ch      = foot < back ? min(rise(Foot_cone), (body_h - flare_h - fh) / 2) : 0;
    union() {
        if (ch > 0) {                                     // the foot, and the cone in
            linear_extrude(height = fh + 0.01) offset(delta = -foot) top_2d();
            translate([0, 0, fh])
                flare(ch) {
                    offset(delta = -foot) top_2d();
                    offset(delta = -back) top_2d();
                }
        }
        // the column — over-long by a hair, so it meets the flare in one solid
        translate([0, 0, fh + ch])
            linear_extrude(height = body_h - flare_h - fh - ch + 0.01)
                offset(delta = -back) top_2d();
        translate([0, 0, body_h - flare_h])               // out to the top
            flare(flare_h) {
                offset(delta = -back) top_2d();
                top_2d();
            }
        translate([0, 0, body_h])
            linear_extrude(height = slab) top_2d();
    }
}

// The pockets are cut in the BOTTOM face, which is the foot of the pedestal — narrower
// than the top on every side — so the row is laid out on that foot, not on the top. On the
// full top the outer pockets would sit right outside the pedestal and break through the
// flare.
module pedestal_magnets(w, d) {
    slab    = min(rise(Top_h), Print_h / 2);
    flare_h = (Print_h - slab) * Flare;
    foot    = foot_back(w, d, flare_h);
    magnets(w - 2 * plan_cm(foot), d - 2 * plan_cm(foot), Magnets);
}

// How far the pedestal is set in, printed mm. Clamped two ways, so one number works on
// any size and height: it may not lean out more than 45 deg over the height the flare has
// (which is what keeps the slope printable without support), and it must leave a foot wide
// enough to stand on and to take a magnet pocket.
function back(w, d, flare_h) =
    max(0, min(cm(Setback), flare_h,
               (min(cm(w), cm(d)) - magnet_min_span(magnet_d_for(w, d)) - 0.1) / 2));

// ... and how far the FOOT under it is set in: Foot_out closer to the edge than the
// column, but never past it — a foot may only ever spread, never pinch in.
function foot_back(w, d, flare_h) =
    max(0, back(w, d, flare_h) - cm(Foot_out));

// The outline of the top — everything else is built from it.
module top_2d() {
    if (Round) footprint_round_2d(Diameter);
    else       footprint_2d(Width, Depth);
}
