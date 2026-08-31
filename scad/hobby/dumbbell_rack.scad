// hobby / dumbbell_rack — a tiered dumbbell rack: a stepped A-frame stand carrying rows of
// dumbbells that ascend from a low front tier to a tall back one. Like the weight bench it
// reads by its MASS — the ranks of paired weights — and not by any bar or cable, which do not
// print at 1:40 (see weight_bench.scad and §1.3).
//
// The stand is a terraced block: full-width steps rising toward the back (+Y), each step's tread
// a shelf a row of dumbbells sits on, so from a low front angle you see the ranks of weights
// stepping up — the shape of a real dumbbell rack. A dumbbell is two fat weight discs on a short
// handle, lying along the row with its underside FLATTENED so it rests on the tread and prints
// with no overhang (you see its upper half, the way a dumbbell sits in a cradle); the handle is
// held to a printable minimum, because a real handle is under a millimetre at 1:40 and would
// vanish or snap. Nothing bridges or spikes — the steps are solid and carry the tread above them.
//
// Width/Depth are the real-world footprint in cm — a rack about 100 x 50 — and Height the real
// height over the back rank of dumbbells, shrunk by the plan scale (see printed_h() in
// lib/common.scad). It prints the right way up, with the magnet pockets in the broad base.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 50;   // cm
Height = 75;   // cm — over the back rank of dumbbells

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_dumbbells = true;
// The tiers, front (low) to back (high), and one rank of dumbbells on each tread.
Tiers      = 3;    // ranks of weights
Tier_drop  = 15;   // cm each tread drops from the one behind it
// A dumbbell, real cm: two weight discs of Weight_d on a Handle_l handle, discs Weight_t thick.
Weight_d   = 13;   // cm — a weight disc ...
Weight_t   = 5;    // ... how thick it is, along the handle ...
Handle_l   = 11;   // ... and the handle between the two discs
Handle_d   = 5;    // cm — the handle, clamped to a printable minimum (see dumbbell())
Row_margin = 8;    // cm kept clear at each end of a rank
Pair_gap   = 7;    // cm between dumbbells along a tread

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the piece
// from pivoting; the broad base is the whole footprint (see Magnet_* in lib/common.scad).
Magnets = 2;

dumbbell_rack();

// The depth of one tread band, and the tread height of tier i (0 = front, lowest): the back
// tier tops out one weight-disc below Height so its dumbbells reach full height, and each tier
// forward drops Tier_drop, clamped so the front tread never sinks below the base.
function step_d()   = cm(Depth) / Tiers;
function tread_z(i) = max(rise(8),
                          Print_h - rise(Weight_d) - (Tiers - 1 - i) * rise(Tier_drop));

module dumbbell_rack() {
    if (tread_z(0) <= rise(8))
        echo(str("NOTE: ", Tiers, " tiers dropping ", Tier_drop, " cm each do not fit a ",
                 Height, " cm rack — the front tread is clamped to the base (give it more: ",
                 "Height, or fewer Tiers / a smaller Tier_drop)"));
    difference() {
        union() {
            // the terraced stand: a full-width block per tier, each starting further back and
            // standing higher, so their union steps up toward +Y
            for (i = [0 : Tiers - 1]) {
                d = cm(Depth) - i * step_d();               // this tier's block runs to the back
                translate([0, -cm(Depth) / 2 + i * step_d() + d / 2, tread_z(i) / 2])
                    cube([cm(Width), d, tread_z(i)], center = true);
            }
            if (Show_dumbbells)
                for (i = [0 : Tiers - 1]) dumbbell_row(i);
        }
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// One rank of dumbbells, on the exposed front strip of tier i's tread. As many as fit the width
// clear of Row_margin at each end, centred on the piece.
module dumbbell_row(i) {
    y = -cm(Depth) / 2 + i * step_d() + step_d() / 2;   // centre of tier i's exposed tread
    z = tread_z(i);
    span = cm(Handle_l) + 2 * cm(Weight_t);             // one dumbbell, along the row
    pitch = span + cm(Pair_gap);
    room  = cm(Width) - 2 * cm(Row_margin);
    n     = max(1, floor((room + cm(Pair_gap)) / pitch));
    for (k = [0 : n - 1])
        translate([-(n - 1) * pitch / 2 + k * pitch, y, z])
            dumbbell();
}

// One dumbbell, lying along X and resting on the tread at z = 0: two weight discs on a thin
// handle, the whole thing intersected with a half-space at its axis so the underside is flat —
// it sits on the shelf and prints with no sub-floor overhang, and you see its upper half. The
// handle is clamped to Symbol_min so it never falls below one nozzle.
module dumbbell() {
    hl = cm(Handle_l);
    wt = cm(Weight_t);
    wd = cm(Weight_d);
    hd = max(Symbol_min, cm(Handle_d));
    r  = wd / 2;
    intersection() {
        union() {
            rotate([0, 90, 0]) cylinder(h = hl + 2 * wt, d = hd, center = true);   // the handle
            for (s = [-1, 1])                                                       // the discs
                translate([s * (hl / 2 + wt / 2), 0, 0])
                    rotate([0, 90, 0]) cylinder(h = wt, d = wd, center = true);
        }
        // keep only what is at or above the axis, so the dumbbell has a flat bottom on the tread
        translate([0, 0, r]) cube([hl + 2 * wt + 1, wd + 1, wd], center = true);
    }
}
