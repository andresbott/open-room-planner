// outdoor / chair — a patio chair token that turns into a sun lounger: Lounger
// swaps the footprint from a square chair seat to a long reclining mattress, the
// way table.scad's Round swaps a rectangular top for a round one.
//
// Width/Depth are the chair's real-world seat footprint in cm; Lounger_width/
// Lounger_length are the real-world lounger footprint used instead once
// Lounger=true. The heights are real cm too, and each shape has its own: a chair
// is a Seat with its back rising to Height, a lounger a low frame (Lounger_h) with
// the head end climbing Wedge_h off it. The block is whichever of the two the shape
// stands on; the pads rise off it (see printed_h() / rise() in lib/common.scad).

include <../lib/common.scad>

Width  = 55;   // cm, chair seat footprint (Lounger=false)
Depth  = 55;   // cm, chair seat footprint (Lounger=false)
Lounger_width  = 60;   // cm, lounger footprint (Lounger=true)
Lounger_length = 190;  // cm, lounger footprint (Lounger=true)
Height = 85;   // cm, chair: top of the back
Arm    = 62;   // cm, chair: top of the arms
Seat   = 42;   // cm, chair: seat height
Lounger_h = 30;  // cm, lounger: the frame the mattress lies on

Lounger   = false;  // true -> a long sun lounger instead of a square chair
Show_back = true;   // toggle for the raised back cushion / back wedge

// the printed height of the block, mm — a chair's seat or a lounger's frame
Base_z = printed_h(Lounger ? Lounger_h : Seat);

// Raised pads, real-world cm, and the gap kept around and between them — the
// same margin on both shapes, like Pillow_gap in bed.scad.
Pad_gap = 3;  // cm

// Chair (Lounger=false): back cushion depth and arm cushion width.
Back_d = 15;  // cm
Arm_w  = 9;   // cm
// The arm cushions are narrow: Cushion_radius would collapse a pad this thin
// at 1:40 (9 cm is 2.25 mm), so they round with a smaller radius instead (still
// one nozzle+).
Arm_radius = 0.5;  // mm

// Lounger (Lounger=true): the raised back-wedge zone at the head end (+Y) — a
// flat run where it meets the mattress, a flat top at the head edge, and a
// plain slope between the two (see back_wedge() below).
Wedge_len    = 45;  // cm, total length of the zone
Wedge_base_d = 16;  // cm, flat run at the mattress end
Wedge_peak_d = 14;  // cm, flat top at the head edge
Wedge_h      = 25;  // cm, how far the peak climbs above the mattress top

// Magnet pockets in the bottom face, in a row along the longer side (0 = none).
// Two keep the piece from pivoting on the board; the count auto-clamps to what
// fits — at 1:40 both shapes take the pair (the square chair is 13.75 mm across,
// just wide enough for two pockets in a row) — see Magnet_* in lib/common.scad.
Magnets = 2;

chair();

module chair() {
    w = Lounger ? Lounger_width  : Width;
    d = Lounger ? Lounger_length : Depth;
    union() {
        difference() {
            footprint(w, d, Base_z);
            if (Magnets > 0)
                magnets(w, d, Magnets);
        }
        if (Lounger) lounger_pads(w, d);
        else         chair_pads(w, d);
    }
}

// A chair reads from a low angle by its back and arms: a back cushion along the
// rear edge (+Y, gated by Show_back) and an arm cushion down each side — always
// on, since they are what still reads "chair" with the back switched off.
module chair_pads(w, d) {
    ad = d - Back_d - 3 * Pad_gap;   // depth left for the arm cushions
    ay = -d / 2 + Pad_gap + ad / 2;
    for (x = [-1, 1])
        translate([x * cm(w / 2 - Pad_gap - Arm_w / 2), cm(ay), 0])
            cushion(Arm_w, ad, Base_z, Arm - Seat, r = Arm_radius);
    if (Show_back)
        translate([0, cm(d / 2 - Pad_gap - Back_d / 2), 0])
            cushion(w - 2 * Pad_gap, Back_d, Base_z, Height - Seat);
}

// A lounger reads by its mattress and its raised head end: a long flat mattress
// over most of the length, and — gated by Show_back — a wedge that climbs from
// the mattress top up to the head edge (+Y) instead of a hinged, overhanging
// backrest, so the piece stays one solid, support-free block.
module lounger_pads(w, d) {
    mw = w - 2 * Pad_gap;
    md = d - Wedge_len - 3 * Pad_gap;   // mattress length, leaving the wedge its zone
    my = -d / 2 + Pad_gap + md / 2;
    translate([0, cm(my), 0])
        cushion(mw, md, Base_z);
    if (Show_back) {
        wz0 = my + md / 2 + Pad_gap;    // the wedge zone starts here...
        wz1 = d / 2 - Pad_gap;          // ...and ends at the head edge
        back_wedge(mw, wz0 + Wedge_base_d / 2, Wedge_base_d,
                       wz1 - Wedge_peak_d / 2, Wedge_peak_d,
                       Base_z, Wedge_h);
    }
}

// The lounger's back wedge — built the way cushion() is (a hull of two
// footprints at different heights) but shifted along Y, between a low
// <base_d>-deep footprint at <base_y> and a narrower, self-tapered
// <peak_d>-deep one <h_cm> real cm higher at <peak_y>, instead of both centred on
// the same spot. The hull between them climbs at a steady slope rather than
// stepping, so every layer sits on the one below it — no floating overhang.
module back_wedge(w_cm, base_y, base_d, peak_y, peak_d, base_z, h_cm,
                   taper = Cushion_taper, r = Cushion_radius) {
    hull() {
        translate([0, cm(base_y), base_z - 0.01])
            linear_extrude(height = 0.01) footprint_2d(w_cm, base_d, r);
        translate([0, cm(peak_y), base_z + rise(h_cm)])
            linear_extrude(height = 0.01)
                offset(delta = -taper) footprint_2d(w_cm, peak_d, r);
    }
}
