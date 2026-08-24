// office / desk — a desk token, built like table.scad and console.scad: a thin
// top slab standing proud of a set-back body on four corner legs, kept as one
// solid, support-free block. No place_setting is engraved — that symbol reads
// as a dining table, and a desk is worked at, not eaten at.
//
// Width/Depth are the real-world top in cm: a single 120 x 60 writing desk (a
// 160 x 80 double-width variant is the same part, just override both). Height is
// the real height of the top — desk height, a touch under a dining table — shrunk
// by the plan scale like the footprint (see printed_h() in lib/common.scad), same
// as table.scad.

include <../lib/common.scad>

Width  = 120;  // cm — a 160x80 variant is the same part, wider and deeper
Depth  = 60;   // cm
Height = 74;   // cm — desk height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its
// edge is the line you read the size off. Same idea as table.scad.
Top_h = 4;
// How far the body under the top is set back from the edge, in real cm.
// Clamped below exactly like table.scad/console.scad: it may not lean past 45
// deg (body_h) and must leave a base wide enough for a magnet pocket.
Setback = 16;
// A leg at each corner, flush with the edge of the top, so the corners read
// solid while the body slopes away between them (see table.scad).
Show_legs = true;
Leg       = 7;   // cm

// A shallow seam hinting at a drawer pedestal under one end of the top,
// instead of the full drawers() symbol — a desk pedestal reads as one seam,
// not a row of fronts. It sits Pedestal_w in from the +X end (the right-hand
// return as you face the desk from the front, -Y), leaving the rest of the
// top open for a kneehole. Off by default so a plain writing desk / trestle
// stays plain.
Show_drawers = false;
Pedestal_w   = 40;  // cm, width of the pedestal from the +X end
Pedestal_gap = 3;   // cm kept clear from the front/back edges
Seam_w       = 2;   // cm, thickness of the seam line — ~0.5 mm printed

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad. At 60 cm
// depth (15 mm at 1:40) the 4 mm disc fits fine.
Magnets = 2;

desk();

module desk() {
    body_h = Print_h - rise(Top_h);
    // Same clamp as table.scad/console.scad: never lean past 45 deg, and
    // always leave a base wide enough to stand on and take a magnet pocket.
    base_min = magnet_min_span(magnet_d_for(Width, Depth));
    back = max(0, min(cm(Setback), body_h,
                       (min(cm(Width), cm(Depth)) - base_min) / 2));
    difference() {
        union() {
            // the body: full footprint where it meets the top, set back at the floor
            hull() {
                linear_extrude(height = 0.01)
                    offset(delta = -back) footprint_2d(Width, Depth);
                translate([0, 0, body_h - 0.01])
                    linear_extrude(height = 0.01) footprint_2d(Width, Depth);
            }
            if (Show_legs) legs(body_h);
            translate([0, 0, body_h])
                linear_extrude(height = rise(Top_h)) footprint_2d(Width, Depth);
        }
        if (Show_drawers)
            groove(Width / 2 - Pedestal_w, 0, Seam_w,
                   Depth - 2 * Pedestal_gap, Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// Legs, <h> mm tall, clipped to the outline so a rounded corner stays rounded —
// same technique as table.scad's legs(), rectangular only (a desk has no round
// variant).
module legs(h) {
    intersection() {
        linear_extrude(height = h) footprint_2d(Width, Depth);
        for (x = [-1, 1], y = [-1, 1])
            translate([x * (cm(Width) - cm(Leg)) / 2,
                       y * (cm(Depth) - cm(Leg)) / 2, h / 2])
                cube([cm(Leg), cm(Leg), h], center = true);
    }
}
