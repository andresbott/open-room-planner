// hallway / console — a console / hall table token: a narrow table meant to
// stand against a wall, built like diningroom/table.scad's "stands proud"
// trick — a thin top slab over a body set back from the edge, with a leg at
// each corner, kept as one solid, support-free block.
//
// Width/Depth are the real-world top in cm: a console runs the length of a
// hallway wall (Width) but stays shallow front-to-back (Depth), so it reads
// on the plan as a thin strip rather than a full table. Height is the real height
// of the top — a hall console stands a little above table height — shrunk by the
// plan scale like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 35;   // cm
Height = 80;   // cm — the top

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its
// edge is the line you read the size off. At 8 cm (2 mm printed) the proud top edge is sturdy
// and reads as a table top; a 4 cm top was a fragile 1 mm wafer standing off the body.
Top_h = 8;
// How far the body under the top is set back from the edge, in real cm. It
// stands in for the open space under a real console, but it is a slope, not
// a step, and it is clamped below (see console()) — on a top this shallow
// the clamp mostly wins, so the body ends up close to full width anyway.
Setback = 16;
// A leg at each corner of the top, Leg cm square, flush with the edge.
Show_legs = true;
Leg       = 7;   // cm

// A single drawer seam under the front edge (-Y), cut into the top face: a
// thin groove hinting at one drawer without a full drawers() symbol on a top
// this shallow. Off by default — most consoles in this set are open shelves.
Show_drawer = false;
Drawer_w    = 70;  // cm, seam width, centred on the piece
Drawer_gap  = 5;   // cm, how far the seam sits in from the front edge
Drawer_seam = 2;   // cm, seam thickness — prints about one Symbol_stroke wide

// Magnet pockets in the bottom face, in a row along the length (0 = none).
// Two keep the piece from pivoting on the board; see Magnet_* in
// lib/common.scad. A 35 cm-deep top is 8.75 mm across at 1:40 — wide enough
// for a 4 mm disc.
Magnets = 2;

console();

module console() {
    body_h   = Print_h - rise(Top_h);
    // Clamped exactly like table.scad: never lean out more than 45 deg
    // (body_h), and always leave a base wide enough for a magnet pocket.
    base_min = magnet_min_span(magnet_d_for(Width, Depth));
    back     = max(0, min(cm(Setback), body_h,
                          (min(cm(Width), cm(Depth)) - base_min) / 2));
    difference() {
        union() {
            // the body: full footprint where it meets the top, set back at
            // the floor
            hull() {
                linear_extrude(height = 0.01)
                    offset(delta = -back) footprint_2d(Width, Depth);
                translate([0, 0, body_h - 0.01])
                    linear_extrude(height = 0.01) footprint_2d(Width, Depth);
            }
            if (Show_legs)
                legs(body_h);
            translate([0, 0, body_h])
                linear_extrude(height = rise(Top_h)) footprint_2d(Width, Depth);
        }
        if (Show_drawer)
            groove(0, -(Depth / 2 - Drawer_gap), Drawer_w, Drawer_seam, Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// Legs, <h> mm tall, clipped to the outline so a rounded corner stays
// rounded — one at each corner of the top.
module legs(h) {
    intersection() {
        linear_extrude(height = h) footprint_2d(Width, Depth);
        for (x = [-1, 1], y = [-1, 1])
            translate([x * (cm(Width) - cm(Leg)) / 2,
                       y * (cm(Depth) - cm(Leg)) / 2, h / 2])
                cube([cm(Leg), cm(Leg), h], center = true);
    }
}
