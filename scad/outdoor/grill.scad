// outdoor / grill — a freestanding gas barbecue on a cart: a cooking box on a cabinet, built
// on the same fitted-unit body as a kitchen run (base_unit() in lib/common.scad), with the
// things that say "grill" and not "cooker". It shares a lot with kitchen/cooker.scad on
// purpose — both are an oven-ish cabinet with controls on the front — so it has to differ where
// a glance lands:
//
//   - the cooking surface is a sunken FIREBOX with a bar GRATE (parallel ridges), not the
//     cooker's four round dished burners. Grill bars run front-to-back, the way food sits on
//     them and the way a low angle reads the lines;
//   - a LID hump rises along the back of the firebox — the dome parked open — so from the side
//     the piece has a barbecue's humped silhouette and not a flat counter;
//   - only half the top is firebox; the other half is a side PREP shelf with a single round
//     side burner, which is what a cart grill carries and a slot-in cooker does not.
//
// The controls still go on the FRONT (-Y) face — a row of knob dips over the firebox on a
// fascia, with the cart's cupboard doors under it (the propane bottle lives in there) — because
// that is where a grill's are and where a low angle can see them. The knobs are dips and not
// buds for the usual reason (§1.3): a 1 mm stub snaps off. Nothing stands off a face; the lid
// hump is a tapered pad (cushion()) that prints support-free, and every step up the body is a
// 45 deg flare, so it prints the right way up like any base unit, magnet pocket in the plinth.
//
// Width/Depth are the real-world footprint in cm — a typical three-burner cart is about
// 120 x 60 — and Height the real cooking-surface height (counter height, ~90 cm), shrunk by the
// plan scale (see printed_h() in lib/common.scad); the lid stands its own real height above it.

include <../lib/common.scad>

Width  = 120;  // cm
Depth  = 60;   // cm
Height = 90;   // cm — the cooking surface, at counter height; the lid rises above it

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top, real cm — the same worktop slab as the run it stands beside (see worktop.scad).
Slab = Unit_top;

// -- The firebox and grate ----------------------------------------------------
Show_grate = true;
// The cooking box sits on the LEFT of the top; the prep shelf takes the rest. Real cm.
Grill_w      = 64;   // cm — the firebox opening across the top ...
Edge         = 6;    // ... and the worktop rim left round it (and between it and the prep)
Firebox_depth = 6;   // cm the firebox pan sinks below the worktop
// The grate: ridges left standing between parallel slots, running front-to-back across the box.
Grate_pitch  = 6;    // cm from one bar to the next ...
Grate_gap    = 2;    // ... the slot cut between them ...
Grate_cut    = 3;    // ... and how much deeper than the pan floor it goes

// -- The lid hump -------------------------------------------------------------
Show_lid = true;
Lid_h    = 28;   // cm the lid stands above the worktop, along the back of the firebox
Lid_d    = 26;   // cm of the firebox depth it covers (the back part — parked open)

// -- The side burner ----------------------------------------------------------
Show_side_burner = true;
Side_burner_d     = 22;   // cm — one gas ring on the prep shelf, a real dished hollow
Side_burner_depth = 1;    // printed mm it dishes in — drawing detail, so it does not scale

// -- The front: controls and cabinet ------------------------------------------
Show_front = true;
Fascia  = 7;   // cm of the face the control fascia takes (deep enough to hold the knobs)
Burners = 3;   // control knobs across the firebox ...
Knob_d  = 4;   // ... each this many cm across ...
Knob_cut = 0.4;// ... sunk this many mm below the fascia
Doors   = 2;   // cupboard doors across the cart under the fascia

// Magnet pockets in the bottom face (0 = none), in a row along the width. They go in the
// plinth — the face that really meets the board — as everywhere in a fitted run (see
// unit_plinth_d() and Magnet_* in lib/common.scad). A 120 cm cart takes two so it cannot pivot.
Magnets = 2;

// ---- the zones on the top, real cm ------------------------------------------
// The firebox centre, set in from the left by the rim; the prep shelf fills what is left on
// the right, with the side burner in the middle of it.
function firebox_cx() = -Width / 2 + Edge + Grill_w / 2;
function firebox_d()  = Depth - 2 * Edge;
function prep_x0()    = -Width / 2 + 2 * Edge + Grill_w;
function prep_x1()    = Width / 2 - Edge;
function prep_cx()    = (prep_x0() + prep_x1()) / 2;

grill();

module grill() {
    z0 = unit_face_z0(Width, Depth, Print_h, Slab);   // the carcass face, bottom ...
    z1 = unit_face_z1(Width, Depth, Print_h, Slab);   // ... and top
    union() {
        difference() {
            base_unit(Width, Depth, Print_h, Slab);
            if (Show_grate)       { firebox_pan(); grate(); }
            if (Show_side_burner) side_burner();
            if (Show_front) {
                unit_fascia(Width, Depth, z1, Fascia, Slab);
                knobs(z1 - rise(Fascia) / 2);
                unit_fronts(Width, Depth, z0, z1 - rise(Fascia), Doors, 1, Slab);
            }
            if (Magnets > 0)
                magnets(Width, unit_plinth_d(Width, Depth), Magnets);
        }
        if (Show_lid) lid();
    }
}

// The firebox pan: a shallow rectangular recess in the worktop over the cooking area, so the
// grate sits in a box with a rim round it rather than flush with the counter.
module firebox_pan() {
    translate([cm(firebox_cx()), 0, Print_h - rise(Firebox_depth)])
        linear_extrude(height = rise(Firebox_depth) + 0.1)
            footprint_2d(Grill_w, firebox_d());
}

// The grate: parallel slots cut into the pan floor, front-to-back, spaced Grate_pitch apart and
// kept off the firebox walls — what is left standing between them are the bars.
module grate() {
    usable = Grill_w - Grate_gap - 2 * Symbol_margin;
    n      = max(1, floor(usable / Grate_pitch) + 1);
    span   = (n - 1) * Grate_pitch;
    z      = Print_h - rise(Firebox_depth) - rise(Grate_cut);
    for (i = [0 : n - 1]) {
        x = cm(firebox_cx()) + cm(n > 1 ? -span / 2 + i * Grate_pitch : 0);
        translate([x - cm(Grate_gap) / 2, -cm(firebox_d()) / 2, z])
            cube([cm(Grate_gap), cm(firebox_d()), rise(Firebox_depth) + rise(Grate_cut) + 0.1]);
    }
}

// The side burner: one dished ring on the prep shelf, the hob hollow one size down (see
// cooker.scad). Clamped so it stays clear of the shelf edges.
module side_burner() {
    d = min(Side_burner_d, prep_x1() - prep_x0() - 2 * Symbol_margin,
            Depth - 2 * Edge - 2 * Symbol_margin);
    if (d > 0)
        translate([cm(prep_cx()), 0, 0])
            hollow(Print_h, Side_burner_depth) circle(d = cm(d));
}

// The lid hump: a tapered pad along the back of the firebox, standing Lid_h above the worktop —
// the dome parked open. cushion() tapers in on the way up, so it prints support-free.
module lid() {
    y = cm(Depth / 2 - Edge - Lid_d / 2);
    translate([cm(firebox_cx()), y, 0])
        cushion(Grill_w, Lid_d, Print_h, Lid_h);
}

// The knobs: a row of round dips in the fascia at height <z>, spread across the FIREBOX width
// (the controls sit over the box they light), inside a margin. Dips, not buds — the same call
// the grip slots and the cooker's knobs make (see Grip_h / knobs() in cooker.scad).
module knobs(z, n = Burners, d_cm = Knob_d, cut = Knob_cut) {
    d    = cm(d_cm);
    span = max(0, cm(Grill_w) - d - 2 * Symbol_margin);
    face = unit_face_d(Width, Depth, Slab);
    for (i = [0 : n - 1]) {
        x = cm(firebox_cx()) + (n > 1 ? -span / 2 + span * i / (n - 1) : 0);
        translate([x, -cm(face) / 2 - 0.1, z])
            rotate([-90, 0, 0])
                cylinder(h = Front_relief + cut + 0.1, d = d);
    }
}
