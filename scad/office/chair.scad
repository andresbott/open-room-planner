// office / chair — a swivel task-chair token. Nothing about it is the dining chair
// (diningroom/chair.scad, a square seat block with a flat pad at the back and
// another on the seat): this one is made of the three things that say office chair
// at a glance — a five-star base on castors, a round seat up on a pedestal column,
// and a backrest that curves round the rear of the seat, with an armrest each side.
//
// In section, across the chair:
//
//         ___              the backrest, a shell following the seat rim ...
//    ___ |   | ___         ... the armrests each side of it ...
//   |_______________|      ... the seat, standing on ...
//         \     /          ... a flare, at most 45 deg so it prints without support
//          |   |           ... the column, straight down to ...
//      ___ |   | ___       ... the five-star base: fins out to the castors, with
//     |_______________|     the magnet pocket in the middle of it
//
// It prints the right way up and support-free: every face either rises straight or
// leans out no more than 45 deg, and the pocket opens at the floor as everywhere
// else. From above you read it off the star sticking out past the seat, the arms and
// the curved back — a token you cannot mistake for a dining chair on the plan.
//
// Base is the real-world footprint in cm: a task chair stands on its base, which is
// wider than its seat (a 65 cm star under a 50 cm seat), so the base is what the
// token takes up on the plan. The heights are real cm: Height is the top of the
// backrest — how tall the chair is — and Seat the seat it rises from (see printed_h()
// / rise() in lib/common.scad).

include <../lib/common.scad>

Base     = 65;  // cm — across the five-star base, the chair's footprint
Diameter = 50;  // cm — the seat
Height   = 95;  // cm — top of the backrest
Seat     = 47;  // cm — seat height, wound up to desk height

// the printed height of the seat, mm — the back and the arms stand on it
Seat_z = printed_h(Seat);

Show_base = true;
// The five-star base, in real cm: fins radiating from the column out to the castors,
// as tall as a castor and the base moulding it hangs off.
Fins     = 5;
Base_h   = 6;
Fin_w    = 10;  // cm, how wide a fin is where it leaves the column ...
Castor_d = 6;   // ... and at the castor on its tip
// The gas-lift column, in real cm. A real one is ~10 cm across, which is 2.5 mm at
// 1:40 and no home for a magnet, so the token's column is as fat as the pocket in its
// foot needs — see column_d(). It is hidden under the seat from above anyway.
Column_d = 26;
// The seat slab, in real cm, and how the space under it is split: this share of it
// flares out into the seat, the rest is straight column (as in table.scad).
Seat_h = 8;
Flare  = 0.55;

Show_back = true;
// The backrest, in real cm: a shell on the rim of the seat rather than a flat pad —
// the curve is what reads as a task chair. It rises from the seat to Height.
Back_t     = 6;   // cm thick
Back_wrap  = 14;  // cm it reaches forward from the rear rim, so it wraps and stops
Back_inset = 2;   // cm kept between the shell and the rim of the seat

Show_arms = true;
// The armrests, in real cm — a pad each side of the seat, clipped to the seat rim so
// they cannot hang out over it (see arms()).
Arm_w   = 8;
Arm_d   = 24;
Arm_h   = 18;  // cm above the seat — armrest height, ~65 cm off the floor
Arm_gap = 1;   // cm kept off the rim
// A pad this narrow (8 cm is 2 mm at 1:40) would collapse under Cushion_radius —
// footprint_2d() shrinks an outline and grows it back, and there would be nothing
// left to grow from — so the arms round with a smaller radius, like the outdoor
// chair's arms do.
Arm_radius = 0.5;  // mm

// Magnet pockets in the bottom face (0 = none). The base is the same in every
// direction and the pocket sits in the foot of the column, dead centre, so one is
// all it can take and all it needs; see Magnet_* in lib/common.scad.
Magnets = 1;

chair();

module chair() {
    base_h = rise(Base_h);
    slab_h = rise(Seat_h);
    // the space between the base and the underside of the seat: column plus flare
    body_h = max(0, Seat_z - slab_h - base_h);
    // The flare may not lean out more than 45 deg, so it has to be at least as tall
    // as it is wide. Where the space cannot give it that, the column comes out fatter
    // instead of the slope steeper — table.scad caps its set-back the same way.
    flare_h = min(body_h, max(body_h * Flare, (cm(Diameter) - cm(column_d())) / 2));
    col     = max(cm(column_d()), cm(Diameter) - 2 * flare_h);  // printed mm
    col_h   = body_h - flare_h;
    difference() {
        union() {
            if (Show_base) star_base(base_h, col);
            // the column, straight up (over-long by a hair, so it meets the flare
            // in one solid), then the flare out to the full seat
            cylinder(h = base_h + col_h + 0.01, d = col);
            translate([0, 0, base_h + col_h])
                cylinder(h = flare_h + 0.01, d1 = col, d2 = cm(Diameter));
            translate([0, 0, Seat_z - slab_h]) footprint_round(Diameter, slab_h);
            if (Show_back) backrest();
            if (Show_arms) arms();
        }
        // the pocket goes in the foot of the column, which is the only part of the
        // piece thick enough to bury it — so it is measured on the column, not on
        // the star base it sits in the middle of
        if (Magnets > 0)
            magnets(plan_cm(col), plan_cm(col), Magnets);
    }
}

// The five-star base: <n> fins radiating from a column <col> mm across out to the
// castors, all <h> mm tall. Each fin is a hull from a round end buried inside the
// column to a smaller one at the castor, so it merges into the column with nothing
// to weld and comes out tapered with a round castor at its tip. One fin points dead
// back (+Y), which puts the rest symmetric about the middle of the chair.
module star_base(h, col, n = Fins) {
    tip   = cm(Castor_d);
    r_out = max(cm(Base) / 2 - tip / 2, col / 2);
    linear_extrude(height = h)
        for (i = [0 : n - 1])
            rotate(90 + i * 360 / n)
                hull() {
                    translate([col / 4, 0])  circle(d = cm(Fin_w));
                    translate([r_out, 0])    circle(d = tip);
                }
}

// The backrest: a shell standing on the rear of the seat and following its rim. It
// rises straight, so there is nothing to overhang and no taper to give it.
module backrest() {
    translate([0, 0, Seat_z - 0.01])
        linear_extrude(height = rise(Height - Seat) + 0.01) backrest_2d();
}

// Its plan shape: the band between the rim (less Back_inset) and Back_t inside that,
// kept to where it lies no further forward than Back_wrap from the rear of the seat
// — so it wraps round the back and stops, instead of ringing the whole seat.
module backrest_2d() {
    r_out = cm(Diameter) / 2 - cm(Back_inset);
    r_in  = max(0.01, r_out - cm(Back_t));
    intersection() {
        difference() { circle(r = r_out); circle(r = r_in); }
        translate([-2 * r_out, r_out - cm(Back_wrap)])
            square([4 * r_out, 2 * r_out]);
    }
}

// The armrests: a tapered pad each side of the seat, standing Arm_h above it — the
// other thing that tells a task chair from a dining chair from a low angle. They are
// clipped to the seat outline, so an arm can never end up hanging over the rim in mid
// air, and its outer face comes out following the curve of the seat (the same trick
// table.scad uses on its legs to keep a rounded corner rounded).
module arms() {
    intersection() {
        translate([0, 0, Seat_z])
            cylinder(h = rise(Arm_h) + 0.01, d = cm(Diameter));
        union() {
            for (s = [-1, 1])
                translate([s * cm(Diameter / 2 - Arm_gap - Arm_w / 2), 0, 0])
                    cushion(Arm_w, Arm_d, Seat_z, Arm_h, r = Arm_radius);
        }
    }
}

// The column diameter, in real cm: what was asked for, but never narrower than the
// magnet pocket in its foot needs — with a hair of slack, so rounding cannot tip it
// under that and drop the piece to the small disc — and never wider than the seat it
// holds up. A chair with no magnets asks nothing of its column.
function column_d() =
    min(Diameter,
        max(Column_d, Magnets > 0 ? plan_cm(magnet_min_span(Magnet_d) + 0.1) : 0));
