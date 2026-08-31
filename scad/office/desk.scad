// office / desk — a desk token in the standard sizes: a thin top slab at the full
// footprint standing on one panel support at each end, nothing in between, so the
// piece is a U — in section, across the width
//
//      ________________     the top slab, full footprint: the line you read the
//     |_|            |_|    size off, set proud of the supports all round ...
//       |            |      ... on a support at each end, with the kneehole
//       |            |      clear between them, right down to the floor
//
// PRINT IT UPSIDE DOWN — top face on the bed, the U opening upwards. That way the
// slab is the widest face and holds the piece down, the supports only ever rise
// from it so there is nothing to overhang and no kneehole to bridge, and the magnet
// pockets in the feet open upwards for the discs to drop into. The engraved size
// prints against the bed, as table.scad's place setting does.
//
// No place_setting is engraved — that symbol reads as a dining table, and a desk is
// worked at, not eaten at. The size goes on instead: the desk comes in four
// footprints and they are told apart at a glance (see DESK_SIZES in the Makefile).
//
// Width/Depth are the real-world top in cm — 120x60, 140x70, 150x80, 160x80.
// Height is the real height of the top — desk height, a touch under a dining table
// — shrunk by the plan scale like the footprint (see printed_h() in lib/common.scad),
// same as table.scad.

include <../lib/common.scad>

Width  = 120;  // cm — 120x60, 140x70, 150x80 and 160x80 are the standard tops
Depth  = 60;   // cm
Height = 74;   // cm — desk height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its
// edge is the line you read the size off. Same idea as table.scad — and, like it, at 8 cm
// (2 mm printed) it has the body to survive printing face down; 4 cm was a fragile 1 mm sheet.
Top_h = 8;
// An end support, in real cm. A real gable is 2-3 cm thick, which is a quarter of a
// millimetre at 1:40 and nothing a magnet could live in, so the token's support is
// as wide as the pocket it has to bury — clamped up to that in support_w() — and
// reads as a panel end rather than a leg.
Support_w = 20;
// How far the top overhangs a support, in real cm: the supports are set in from the
// ends and from the front and back edges by this much, so the slab stands proud all
// round and the U is visible from any side.
Support_inset = 4;
// The least clear kneehole left between the two supports, in real cm — what caps a
// support (and the pedestal below) on a narrow desk.
Knee_min = 40;

// The size engraved in the top face, e.g. "160x80". It prints against the bed.
Show_label = true;

// A shallow seam hinting at a drawer pedestal under the +X end of the top (the
// right-hand return as you face the desk from the front, -Y), instead of the full
// drawers() symbol — a desk pedestal reads as one seam, not a row of fronts. The
// support at that end widens to Pedestal_w with it, so the seam falls exactly on
// the inner face of the block you can see underneath. Off by default, so a plain
// writing desk on two panel ends stays plain.
Show_drawers = false;
Pedestal_w   = 40;  // cm, width of the pedestal from the +X end
Pedestal_gap = 3;   // cm kept clear from the front/back edges
Seam_w       = 2;   // cm, thickness of the seam line — ~0.5 mm printed

// Magnet pockets in the bottom face, which is the foot of each support (0 = none).
// Two — one per support, an end of the desk apart — keep the piece from pivoting;
// see desk_magnets() and Magnet_* in lib/common.scad.
Magnets = 2;

desk();

module desk() {
    body_h  = Print_h - rise(Top_h);
    w_minus = support_w(Support_w);
    w_plus  = support_w(Show_drawers ? max(Support_w, Pedestal_w) : Support_w);
    txt     = str(Width, "x", Depth);
    size    = label_size(cm(Width) - 2 * Symbol_margin,
                         cm(Depth) - 2 * Symbol_margin, txt);
    difference() {
        union() {
            support(-1, w_minus, body_h);
            support( 1, w_plus,  body_h);
            translate([0, 0, body_h])
                linear_extrude(height = rise(Top_h)) footprint_2d(Width, Depth);
        }
        if (Show_label && size >= Symbol_min)
            label(txt, Print_h, size);
        if (Show_drawers)
            groove(Width / 2 - Support_inset - w_plus, 0, Seam_w,
                   Depth - 2 * Pedestal_gap, Print_h);
        if (Magnets > 0)
            desk_magnets(w_minus, w_plus);
    }
}

// One end support: a <w_cm> wide block, <h> mm tall, standing at the <s> (+/-1) end
// of the desk and set in from the edges by Support_inset.
module support(s, w_cm, h) {
    translate([s * cm(Width / 2 - Support_inset - w_cm / 2), 0, 0])
        linear_extrude(height = h) footprint_2d(w_cm, support_d());
}

// Magnet pockets, a row per support foot. The shared magnets() rows along the longer
// axis of one rectangle and would lay that row across the kneehole — air — so each
// support is given its own call on its own footprint. The pockets then sit an end of
// the desk apart, which is what stops the piece pivoting on the board. An odd count
// leaves the extra pocket in the -X support.
module desk_magnets(w_minus, w_plus) {
    n_minus = ceil(Magnets / 2);
    for (sup = [[-1, w_minus, n_minus], [1, w_plus, Magnets - n_minus]])
        if (sup[2] > 0)
            translate([sup[0] * cm(Width / 2 - Support_inset - sup[1] / 2), 0, 0])
                magnets(sup[1], support_d(), sup[2]);
}

// How wide a support really comes out, in real cm: what was asked for, but never
// narrower than the standard disc needs (min_span_cm), never so wide that the
// kneehole between the two closes below Knee_min, and never past the middle of the
// desk however the numbers are set — the same belt-and-braces clamp table.scad puts
// on its pedestal.
function support_w(want) =
    min(Width / 2 - Support_inset,
        max(min_span_cm(), min(want, (Width - 2 * Support_inset - Knee_min) / 2)));

// ... and how deep, in real cm: the full depth less the overhang front and back,
// again down to what a pocket needs at the least, and never deeper than the top.
function support_d() =
    min(Depth, max(min_span_cm(), Depth - 2 * Support_inset));

// The narrowest a support may be, in real cm, and still bury the standard disc:
// magnet_min_span() with a hair of slack, so rounding cannot tip a support under
// that minimum and drop the piece to the small disc. A desk with no magnets asks
// nothing of its supports, so they are then only as wide as they were told to be.
function min_span_cm() =
    Magnets > 0 ? plan_cm(magnet_min_span(Magnet_d) + 0.1) : 0;
