// bathroom / toilet — a toilet token: a rounded bowl at the front fused to a
// rectangular cistern at the back, with the seat outline and the bowl/cistern
// seam engraved on top.
//
// Width/Depth are the real-world footprint in cm: a compact toilet is about
// 40 wide and 70 deep overall, bowl and cistern together. Height is the real height
// over the cistern — the tallest part of the piece, the seat sits far lower — shrunk
// by the plan scale like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 40;  // cm
Depth  = 70;  // cm
Height = 78;  // cm — over the cistern (the seat is at about 40)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_detail = true;
// How the footprint splits front-to-back: a rounded bowl at the front (-Y)
// fused to a rectangular cistern at the back (+Y), both Width wide, adding up
// to Depth. The bowl only stands Seat high — the cistern behind it is the piece's
// full Height — so the token steps down at the join, and the seat outline is
// engraved on the low part.
Cistern_depth = 18;         // cm — depth of the tank block
Seat          = 40;         // cm — the bowl: seat height
Seat_margin   = 8;          // cm — gap from the bowl's edge to the seat outline
Seat_stroke   = 2.5;        // cm (~0.6 mm printed) — line width of the seat outline

// the printed height of the bowl, mm — the cistern stands the rest
Seat_z = printed_h(Seat);

// Magnet pockets in the bottom face (0 = none). One central pocket is enough
// for a piece this compact. The 40 cm width is only 10 mm at 1:40 — still room
// for the standard 4 mm disc, and narrower than that magnets() drops to the
// 2 mm one on its own (see Magnet_* in lib/common.scad).
Magnets = 1;

toilet();

module toilet() {
    bowl_depth = Depth - Cistern_depth;
    cistern_y  = Depth / 2 - Cistern_depth / 2;
    bowl_y     = -Depth / 2 + bowl_depth / 2;
    seam_y     = Depth / 2 - Cistern_depth;
    difference() {
        union() {
            translate([0, cm(cistern_y), 0])
                footprint(Width, Cistern_depth, Print_h);
            translate([0, cm(bowl_y), 0])
                linear_extrude(height = Seat_z) bowl_2d(Width, bowl_depth);
            // weld: a thin strip straddling the seam, so the bowl and cistern
            // fuse into one solid instead of two blocks that merely touch —
            // they would otherwise only share a coincident face, which CGAL
            // can leave as two separate volumes. It is only as tall as the bowl,
            // the lower of the two.
            translate([0, cm(seam_y), Seat_z / 2])
                cube([cm(Width) - 0.2, 0.1, Seat_z], center = true);
        }
        // the seat is engraved on the bowl; the step up to the cistern behind it
        // marks the join on its own, so nothing is drawn on it
        if (Show_detail)
            seat(bowl_y, bowl_depth, Seat_z);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The bowl outline: a square-backed rectangle (so it seats flush against the
// cistern) hulled with a semicircular cap at the front — the cap spends half
// the width on depth, so the whole shape still measures d_cm front-to-back.
// Centred like footprint_2d(), <w_cm> wide.
module bowl_2d(w_cm, d_cm) {
    w      = cm(w_cm);
    d      = cm(d_cm);
    cap_r  = w / 2;
    rect_d = d - cap_r;
    hull() {
        translate([0, d / 2 - rect_d / 2])
            offset(r = Corner_radius) offset(delta = -Corner_radius)
                square([w, rect_d], center = true);
        translate([0, d / 2 - rect_d])
            circle(r = cap_r);
    }
}

// The seat, engraved as a rounded oval ring inset from the bowl's edge — the
// rim you would see looking down on a real toilet. Cut it like label():
//   difference() { footprint(40, 70, 4); seat(-9, 52, 4); }
module seat(bowl_y, bowl_depth, top_z, depth = Label_depth) {
    sw = Width - 2 * Seat_margin;
    sd = bowl_depth - 2 * Seat_margin;
    r  = cm(min(sw, sd)) * 0.4;
    translate([0, cm(bowl_y), top_z - depth])
        linear_extrude(height = depth + 0.01)
            difference() {
                footprint_2d(sw, sd, r);
                footprint_2d(sw - 2 * Seat_stroke, sd - 2 * Seat_stroke,
                             max(0.1, r - cm(Seat_stroke)));
            }
}
