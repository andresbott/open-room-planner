// outdoor / table — a garden table token with a slatted top, round or square.
//
// Built support-free the way the dining table used to be (diningroom/table.scad
// now stands on a single pedestal): a thin top slab at the full footprint,
// standing on a body set well back from the edge, plus a leg at each corner
// (round tops: round legs round the rim). Only the top slab
// is full size, so it stands proud of its legs like a real table, but the body
// slopes back instead of stepping, so nothing overhangs the printer and the
// piece stays one solid block that sits flat and takes a magnet. Grooved seams
// across the top read as timber decking slats instead of a place setting, so it
// does not get mistaken for the dining table indoors.
//
// Width/Depth (or Diameter, for a round top) are the real-world top in cm, and
// Height the real height of that top — garden-table height — shrunk by the plan
// scale like the footprint (see printed_h() in lib/common.scad), the same as
// diningroom/table.scad.

include <../lib/common.scad>

Round    = false;  // true -> a round top of Diameter; Width/Depth are ignored
Width    = 80;     // cm
Depth    = 80;     // cm
Diameter = 90;     // cm, round tops only
Height   = 74;     // cm — garden-table height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its
// edge is the line you read the size off.
Top_h = 4;
// How far the body under the top is set back from the edge, in real cm. It stands
// in for the empty space under a real table, so the further back the better it
// reads — but it is a slope, not a step, and it is clamped below (see table()).
Setback = 16;
// A leg at each corner of the top (round tops: four round ones round the rim),
// Leg cm square. Legs stand vertically, flush with the edge of the top, so the
// corners read solid while the sides slope away.
Show_legs = true;
Leg       = 7;   // cm

// Parallel grooves across the top, standing in for the seams between decking
// boards. Slat_pitch is the real-world seam-to-seam spacing (one board's width);
// Slat_groove is how wide each seam is cut — 2 cm here is 0.5 mm printed, a hair
// over one nozzle, as a symbol stroke is; Slat_margin keeps the outermost seams off
// the rim (and clear of a rounded corner).
Show_slats  = true;
Slat_pitch  = 9;   // cm
Slat_groove = 2;   // cm
Slat_margin = 6;   // cm

// Magnet pocket in the bottom face — this top is small and square/round, so one
// central pocket is enough to keep it from pivoting; see Magnet_* in
// lib/common.scad.
Magnets = 1;

table();

module table() {
    // one pair of dimensions for both shapes — a round top is Diameter x Diameter
    w      = Round ? Diameter : Width;
    d      = Round ? Diameter : Depth;
    body_h = Print_h - rise(Top_h);
    // The set-back is clamped two ways, so one number works on any size and height:
    // it may not lean out more than 45 deg (body_h), which is what keeps the slope
    // printable without support, and it must leave a base wide enough to stand on
    // and to take a magnet pocket.
    base_min = magnet_min_span(magnet_d_for(w, d));
    back     = max(0, min(cm(Setback), body_h, (min(cm(w), cm(d)) - base_min) / 2));
    difference() {
        union() {
            // the body: full footprint where it meets the top, set back at the floor
            hull() {
                linear_extrude(height = 0.01)
                    offset(delta = -back) top_2d();
                translate([0, 0, body_h - 0.01])
                    linear_extrude(height = 0.01) top_2d();
            }
            if (Show_legs)
                legs(body_h);
            translate([0, 0, body_h])
                linear_extrude(height = rise(Top_h)) top_2d();
        }
        if (Show_slats)
            slats(Print_h);
        if (Magnets > 0)
            magnets(w, d, Magnets);
    }
}

// The outline of the top — everything else is built from it.
module top_2d() {
    if (Round) footprint_round_2d(Diameter);
    else       footprint_2d(Width, Depth);
}

// Legs, <h> mm tall, clipped to the outline so a rounded corner stays rounded.
module legs(h) {
    intersection() {
        linear_extrude(height = h) top_2d();
        union() {
            if (Round)
                for (a = [45 : 90 : 315])
                    translate((cm(Diameter) - cm(Leg)) / 2 * [cos(a), sin(a)])
                        cylinder(h = h, d = cm(Leg));
            else
                for (x = [-1, 1], y = [-1, 1])
                    translate([x * (cm(Width) - cm(Leg)) / 2,
                               y * (cm(Depth) - cm(Leg)) / 2, h / 2])
                        cube([cm(Leg), cm(Leg), h], center = true);
        }
    }
}

// Parallel seams across the top, standing in for the gaps between decking
// boards, spaced Slat_pitch cm apart and kept Slat_margin cm off the rim — the
// same spread-with-margin idea as magnets(). Each line is cut as wide as the top
// itself; on a round top that overshoots the chord at that seam, but a groove
// only removes material where there is some, so it is clipped for free by the
// disc outline. Subtract it from the top face like groove():
//   difference() { footprint(80, 80, 6); slats(6); }
module slats(top_z, depth = Label_depth) {
    w      = Round ? Diameter : Width;
    d      = Round ? Diameter : Depth;
    usable = d - 2 * Slat_margin;
    n      = max(1, floor(usable / Slat_pitch) + 1);
    span   = (n - 1) * Slat_pitch;
    for (i = [0 : n - 1]) {
        y = n > 1 ? -span / 2 + i * Slat_pitch : 0;
        groove(0, y, w, Slat_groove, top_z, depth);
    }
}
