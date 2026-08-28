// kitchen / cooker — a slot-in cooker: an oven under a hob, built on the same body as
// the worktop run it drops into (base_unit() in lib/common.scad), with the two things
// that say cooker and nothing else — a grid of dished burners in the top, and an oven
// door (or two) under a control fascia with a row of knobs on the front (-Y) face.
//
// The burners are real hollows and not engraved rings: a ring is a 0.4 mm line, and
// four of them on a 15 mm square top come out as a smudge in a photo, while a hollow
// that dishes down to a smaller floor catches the light and reads as a hob from any
// angle (the same argument bathtub.scad makes for its basin, one size down). They are
// the two real sizes a 60 cm hob carries, set diagonally, which is what a hob looks
// like from above — not four identical circles.
//
// The knobs sit on the front, where a real cooker's are, rather than in a control strip
// engraved across the back of the top: on a slot-in cooker the back of the top is under
// the worktop's own edge, and a row of dots on the face is what a low angle sees.
//
// Width/Depth are the real-world footprint in cm: a standard slot-in cooker is 60 cm
// square with a 2x2 hob; a wider range is Width=90 with Burner_cols=3 (six burners) and
// Oven_cols=2 (a double oven). Height is the real hob height — a cooker is built to finish
// level with the worktop, so it stays at the run's 90 cm — shrunk by the plan scale like
// the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 60;  // cm
Height = 90;  // cm — the hob, level with the worktop

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The hob top, real cm — the same slab as the worktop it slots into (see worktop.scad).
Slab = Unit_top;

Show_hob = true;
// The burner grid: Burner_cols across by Burner_rows deep, sized big/small like a
// checkerboard — so a 2x2 keeps the big pair on one diagonal and the small on the other
// (what a 60 cm hob looks like from above), and a 3x2 gives a 90 cm range its six.
Burner_cols    = 2;    // burners across the hob (3 for a wide range) ...
Burner_rows    = 2;    // ... and deep
Burner_d       = 20;   // cm — the large zones ...
Burner_d_small = 15;   // ... and the small ones
Burner_depth   = 0.8;  // printed mm each dishes into the top — drawing detail, so it
                       // does not scale

Show_front = true;
// The oven: one full-width door on the carcass face (two side by side for a range's
// double oven), under a control fascia. The fascia is deeper than the standard one
// (Fascia_h) because it has to hold the knobs.
Fascia    = 7;    // cm of the face the control fascia takes
Oven_cols = 1;    // oven doors across the front — 2 for a wide range's double oven
Knobs     = Burner_cols * Burner_rows;  // one control knob per burner ...
Knob_d    = 4;    // ... each this many cm across, as a real knob is ...
Knob_cut  = 0.4;  // ... sunk this many mm below the fascia around it

// Magnet pockets in the bottom face (0 = none). A near-square footprint only needs one
// central pocket to stop it pivoting; it goes in the plinth, as everywhere in the run
// (see unit_plinth_d() and Magnet_* in lib/common.scad).
Magnets = 1;

cooker();

module cooker() {
    z0 = unit_face_z0(Width, Depth, Print_h, Slab);   // the carcass face, bottom ...
    z1 = unit_face_z1(Width, Depth, Print_h, Slab);   // ... and top
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_hob) hob();
        if (Show_front) {
            // the fascia hangs off the top of the face, the oven door fills the rest
            unit_fascia(Width, Depth, z1, Fascia, Slab);
            knobs(z1 - rise(Fascia) / 2);
            unit_fronts(Width, Depth, z0, z1 - rise(Fascia), Oven_cols, 1, Slab);
        }
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}

// The burners, dished into the hob top on a Burner_cols x Burner_rows grid, big and small
// alternating like a checkerboard ((i+j) even is a big zone). The centres are spread so
// the LARGE burner keeps Symbol_margin to the edge of the top, and the smaller ones come
// out with more — so a 2x2 is the big-on-one-diagonal hob and a 3x2 a six-burner range.
module hob() {
    ux = max(0, cm(Width) / 2 - Symbol_margin - cm(Burner_d) / 2);
    uy = max(0, cm(Depth) / 2 - Symbol_margin - cm(Burner_d) / 2);
    for (i = [0 : Burner_cols - 1], j = [0 : Burner_rows - 1]) {
        x = Burner_cols > 1 ? -ux + 2 * ux * i / (Burner_cols - 1) : 0;
        y = Burner_rows > 1 ? -uy + 2 * uy * j / (Burner_rows - 1) : 0;
        translate([x, y, 0])
            hollow(Print_h, Burner_depth)
                circle(d = cm((i + j) % 2 == 0 ? Burner_d : Burner_d_small));
    }
}

// The knobs: a row of round dips cut into the fascia at height <z>, spread across it
// inside the same shadow gap the fascia keeps to the sides. Dips and not raised knobs —
// a 1 mm bud on a printed token snaps off, and this is the same call the grip slots make
// (see Grip_h in lib/common.scad).
module knobs(z, n = Knobs, d_cm = Knob_d, cut = Knob_cut) {
    d    = cm(d_cm);
    // centre to centre: the fascia's own width, less a knob and a margin at each end,
    // so the outermost knob sits inside the fascia instead of biting through its end
    span = max(0, cm(Width) - 2 * cm(Front_gap) - d - 2 * Symbol_margin);
    face = unit_face_d(Width, Depth, Slab);
    for (i = [0 : n - 1]) {
        x = n > 1 ? -span / 2 + span * i / (n - 1) : 0;
        translate([x, -cm(face) / 2 - 0.1, z])
            rotate([-90, 0, 0])
                cylinder(h = Front_relief + cut + 0.1, d = d);
    }
}
