// livingroom / console — a narrow hallway / console table token, built like
// table.scad: a thin top slab standing proud of a set-back body on four corner
// legs, kept as one solid, support-free block. No place setting is engraved —
// a console is walked past, not sat at.
//
// Width/Depth are the real-world top in cm: a hall console typically runs
// 100-120 cm long and only 30-40 cm deep, pushed flat against a wall rather than
// sat around. Height is the real height of the top — a console stands at table
// height — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad). A small 40x40 side/occasional table is the same part at
// Height = 45 instead: coffee-table height rather than console height.

include <../lib/common.scad>

Width  = 110;  // cm — override to 40 (with Depth 40) for a small side-table variant
Depth  = 35;   // cm
Height = 80;   // cm — top of the slab (45 for a side/coffee table)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its
// edge is the line you read the size off. Same idea as table.scad.
Top_h = 4;
// How far the body under the top is set back from the edge, in real cm. Clamped
// below exactly like table.scad: it may not lean past 45 deg (body_h) and must
// leave a base wide enough for a magnet pocket — on a depth this shallow that
// second clamp wins, so by default the body barely sets back at all; building
// with smaller magnets (see Magnets below) frees it to taper properly too.
Setback = 12;
// A leg at each corner, flush with the edge of the top, so the corners read
// solid while the body slopes away between them (see table.scad).
Show_legs = true;
Leg       = 6;   // cm

// A single shallow seam under the front edge of the top, hinting at one wide
// drawer without the full drawers() symbol — a console usually has at most one.
// "Front" is the -Y edge, the one facing into the room when the console stands
// back-to-wall on +Y. The gap/seam below come out 1 mm and 0.5 mm once scaled,
// in line with the engraved symbols' margin and stroke.
Show_drawer = false;
Drawer_gap = 4;   // cm kept clear from the front and side edges
Drawer_d   = 2;   // cm — how deep (Y) the seam line reads

// Magnet pockets in the bottom face, in a row along the length (0 = none). Two
// keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
// The 35 cm depth is 8.75 mm across at 1:40 — wide enough for a 4 mm disc.
Magnets = 2;

console();

module console() {
    body_h = Print_h - rise(Top_h);
    // Same clamp as table.scad: never lean past 45 deg, and always leave a base
    // wide enough to stand on and take a magnet pocket.
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
        if (Show_drawer)
            groove(0, -(Depth / 2 - Drawer_gap - Drawer_d / 2),
                   Width - 2 * Drawer_gap, Drawer_d, Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// Legs, <h> mm tall, clipped to the outline so a rounded corner stays rounded —
// same technique as table.scad's legs(), rectangular only (a console has no
// round variant).
module legs(h) {
    intersection() {
        linear_extrude(height = h) footprint_2d(Width, Depth);
        for (x = [-1, 1], y = [-1, 1])
            translate([x * (cm(Width) - cm(Leg)) / 2,
                       y * (cm(Depth) - cm(Leg)) / 2, h / 2])
                cube([cm(Leg), cm(Leg), h], center = true);
    }
}
