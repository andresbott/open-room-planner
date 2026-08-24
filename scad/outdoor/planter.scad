// outdoor / planter — a plant pot / planter token, round by default (a square
// Width/Depth variant is also supported), with a rim groove and an optional
// inner soil circle engraved on top.
//
// Diameter (round pots, Round = true) or Width/Depth (square pots, Round =
// false) is the real-world footprint in cm, and Height the pot's real height —
// about as tall as it is wide for a plain pot — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad). A tall floor-standing tree
// planter is the same part at Height = 80 or more.

include <../lib/common.scad>

Round    = true;  // true -> a round pot of Diameter; false -> a square Width/Depth one
Diameter = 40;    // cm, round pots only
Width    = 40;    // cm, square pots only
Depth    = 40;    // cm, square pots only
Height   = 40;    // cm — a plain pot (80+ for a tree planter)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_rim  = true;  // toggle for the rim groove + soil detail
// The rim groove sits Rim_inset (real cm) in from the edge; Rim_width is the
// groove line's own width, printed mm like Symbol_stroke — a print detail,
// not a real dimension, so it stays visible at any scale.
Rim_inset = 3;    // cm
Rim_width = 0.8;  // mm

// An optional inner soil circle, set further in than the rim — the earth
// inside the pot, seen from above. It is always round, even on the square
// variant: soil (or a root ball) reads round regardless of the pot's outer
// shape.
Show_soil  = true;
Soil_inset = 8;   // cm

// Magnet pockets in the bottom face (0 = none). One central pocket: a pot is
// small and round or near-square, nothing to pivot on the board. A 40 cm pot
// is only 10 mm across at 1:40 — still room for the 4 mm disc, and a smaller
// pot drops to the 2 mm one on its own (see Magnet_* in lib/common.scad).
Magnets = 1;

planter();

module planter() {
    difference() {
        pot(Print_h);
        if (Show_rim)
            rim(Print_h);
        if (Magnets > 0)
            magnets(Round ? Diameter : Width, Round ? Diameter : Depth, Magnets);
    }
}

// The solid block, round or square, <h> mm tall.
module pot(h) {
    if (Round) footprint_round(Diameter, h);
    else       footprint(Width, Depth, h);
}

// The 2D outline of the pot, round or square — the rim is built from it.
module outline_2d() {
    if (Round) footprint_round_2d(Diameter);
    else       footprint_2d(Width, Depth);
}

// The rim groove: a thin outline set Rim_inset in from the edge (a ring on a
// round pot, a rounded-square outline on a square one), marking the pot's
// lip, plus the optional soil circle further in still. Cut at the same
// shallow depth as label(). Subtract it from the solid like label():
//   difference() { footprint_round(40, 4); rim(4); }
module rim(top_z, depth = Label_depth) {
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                difference() {
                    offset(delta = -cm(Rim_inset)) outline_2d();
                    offset(delta = -cm(Rim_inset) - Rim_width) outline_2d();
                }
                if (Show_soil) soil_2d();
            }
}

// The inner soil circle, sized off the smaller footprint dimension so it
// always fits, round or square pot alike.
module soil_2d() {
    pw     = Round ? Diameter : Width;
    pd     = Round ? Diameter : Depth;
    soil_d = min(cm(pw), cm(pd)) - 2 * cm(Soil_inset);
    if (soil_d > 0) circle(d = soil_d);
}
