// bedroom / bench — an upholstered bench on four splayed corner legs, the shape of
// an IKEA EKENÄSET: a single plump boxed seat cushion standing proud of an open
// wooden frame, a leg at each corner and the apron set back between them, so the
// piece reads as a legged bench and not a lidded box.
//
// It is built the way the dining table is (see diningroom/table.scad): the seat is
// the only part at the full footprint — its edge is the line you read the size off
// — while the frame under it slopes back to leave the legs standing at the corners.
// The legs carry the corners of the cushion, so nothing overhangs the printer, the
// sides read as open space under the seat, and the token still sits flat and takes
// a magnet.
//
// Flip Show_lid on (with Show_seat off) and the frame closes up into a plain solid
// slab carrying a lid seam instead — a storage bench / blanket box.
//
// Width is the real-world footprint in cm: a bed-end bench runs 100 to 160 wide to
// match the bed it sits against (the branded IKEA EKENÄSET is 112 x 48). Depth is
// the seat depth, 40 for the plain benches. Height is the real seat height — the
// top of the cushion, the surface you sit on — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad), so a bench comes out about as low
// as a bed.

include <../lib/common.scad>

Width  = 120;  // cm — 100..160 to match the bed it sits against (EKENÄSET: 112)
Depth  = 40;   // cm — a bench's seat depth (EKENÄSET: 48)
Height = 45;   // cm — seat height, cushion included

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The upholstered seat: a single plump boxed cushion sitting on top of the frame,
// inset a little so the frame and the corner legs show around it. One pad, not a
// row — a single cushion is the EKENÄSET's tell. On by default; it is what reads as
// an upholstered bench and not a bare stool. See cushion() in lib/common.scad — it
// self-tapers, so it prints without support. Seat_h is real cm, like Height: the
// frame under it stands the rest.
Show_seat  = true;
Seat_inset = 2;   // cm of frame / leg left showing around the cushion
Seat_h     = 10;  // cm the cushion stands above the frame

// The legs: one at each corner, Leg cm square, standing the full height of the
// frame under the seat and flush with the edge, with the apron between them sloping
// back (Apron_setback) so there is open space under the bench. This is the dining
// table's body + legs construction (see table.scad). Off gives a plinth bench — a
// slab that just slopes back to a footing, no separate legs.
Show_legs     = true;
Leg           = 6;   // cm — corner leg, square
Apron_setback = 12;  // cm the apron is set back from the edge, between the legs

// A storage bench / blanket box instead: a plain solid slab (no legs, no open
// frame) carrying the seam of a hinged lid — a rim inset from the edge, drawn as
// four grooves so it reads as a line and not a second footprint. Off by default;
// turn it on and Show_seat off for a lidded chest.
Show_lid  = false;
Lid_inset = 3;   // cm the lid seam sits in from the edge

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep
// the piece from pivoting on the board; see Magnet_* in lib/common.scad. At 1:40
// the 40 cm depth is 10 mm across — comfortably wide enough for a 4 mm disc, and
// the apron base is never set back further than a pocket needs (see frame()).
Magnets = 2;

bench();

module bench() {
    // a legged upholstered bench, or — with Show_lid — a plain lidded box
    if (Show_lid) box();
    else          frame();
}

// The open wooden frame: an apron at the full footprint under the seat, sloping
// back to a smaller footing so the sides read as open space, on four corner legs
// standing flush with the edge. Same body + legs trick as the dining table (see
// table.scad): the corners stay solid to carry the seat and print without support,
// while the sides slope in below it. The seat cushion sits on top; the magnets go
// in the footing.
module frame() {
    body_h = Show_seat ? Print_h - rise(Seat_h) : Print_h;
    // the set-back is clamped two ways, as in table.scad: it may not lean out more
    // than 45 deg (body_h), which keeps the slope printable without support, and it
    // must leave a footing wide enough to stand on and to take a magnet pocket.
    base_min = magnet_min_span(magnet_d_for(Width, Depth));
    back     = max(0, min(cm(Apron_setback), body_h,
                          (min(cm(Width), cm(Depth)) - base_min) / 2));
    union() {
        difference() {
            union() {
                // the apron: full footprint under the seat, set back at the floor
                hull() {
                    linear_extrude(height = 0.01)
                        offset(delta = -back) footprint_2d(Width, Depth);
                    translate([0, 0, body_h - 0.01])
                        linear_extrude(height = 0.01) footprint_2d(Width, Depth);
                }
                if (Show_legs)
                    legs(body_h);
            }
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        // the raised pad is what makes the piece read as an upholstered bench
        if (Show_seat)
            seat(body_h);
    }
}

// A leg at each corner, <h> mm tall and Leg cm square, clipped to the footprint so
// a rounded corner stays rounded (as in table.scad). The legs sit under the corners
// of the seat, so the cushion has something to stand on where the apron has sloped
// away.
module legs(h) {
    intersection() {
        linear_extrude(height = h) footprint_2d(Width, Depth);
        for (x = [-1, 1], y = [-1, 1])
            translate([x * (cm(Width) - cm(Leg)) / 2,
                       y * (cm(Depth) - cm(Leg)) / 2, h / 2])
                cube([cm(Leg), cm(Leg), h], center = true);
    }
}

// The upholstered seat: a single plump cushion sitting on the frame at <base_z>,
// inset from the edge so the frame and the leg corners show around it — the
// EKENÄSET's one big pad, not a row of separate cushions.
module seat(base_z, inset = Seat_inset, h = Seat_h) {
    cushion(Width - 2 * inset, Depth - 2 * inset, base_z, h);
}

// A storage bench / blanket box: a plain solid slab at the full footprint carrying
// the lid seam. No legs and no open frame — a box sits flat on the floor.
module box() {
    difference() {
        footprint(Width, Depth, Print_h);
        lid_seam(Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The seam a hinged lid leaves: a rectangular rim inset from the edge, drawn as
// four groove() edges (top, bottom, left, right) instead of one filled cut, so it
// reads as a line around the lid panel and not a second footprint. The line is
// held to one nozzle width in printed mm, converted back to the real-world cm
// groove() takes, so it stays readable at any Scale.
module lid_seam(top_z, inset = Lid_inset) {
    stroke = Symbol_stroke * Scale / 10;  // one nozzle, back-converted to real cm
    hw = Width / 2 - inset;
    hd = Depth / 2 - inset;
    groove(0,   hd, 2 * hw + stroke, stroke, top_z);
    groove(0,  -hd, 2 * hw + stroke, stroke, top_z);
    groove(-hw,  0, stroke, 2 * hd + stroke, top_z);
    groove( hw,  0, stroke, 2 * hd + stroke, top_z);
}
