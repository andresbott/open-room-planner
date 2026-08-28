// livingroom / sofa — a multi-seat token modelled as an upholstered piece rather than
// a box with lines on it: a soft seat cushion you can see the seats in, a reclined back
// split into one cushion per seat, an arm down each side and a throw pillow or two
// tossed into the corner. Set Chaise for an L-shaped sectional. The single-seat sibling
// is armchair.scad, which is built the same way.
//
// In section, front (-Y) on the left:
//
//        ___              the reclined back: its wall (+Y) side stays flush so pieces
//       /   |             butt, its seat-facing face leans back as it rises (backrest())
//      /    |
//     |  __ |             a throw pillow, thrown against the back (pillow(), a diamond)
//     | /  \|__           the seat cushion, standing proud of the seat block, a seam
//    _|/____|__|___       line cut between each seat (the "line" that reads the seats)
//   |              |      the seat block
//   ----------------
//
// Why the detail is where it is: the seats are told by a raised cushion with a seam line
// per division — a flat top is the one place a groove reads and does the job (AGENTS.md
// sanctions "a seat pad line"); the back leans and splits into separate cushions because
// on a tall sloped face separate pads with a gap read far better than a line ever could,
// and that is what tells a sofa from a bench across a table. No feet: a foot at 1:40 is a
// 1 mm spike that snaps off, so the piece stays grounded on a broad face for its magnets.
//
// Width picks the size of a straight sofa: about 150 cm for a 2-seat loveseat, 200 for a
// 3-seat, 240 for a large one (IKEA-ish); Depth is the overall seat depth, back cushion
// included. All real-world cm, as are the heights: Height is the top of the back, Arm the
// top of the arms (lower, as on a real sofa) and Seat the block the cushions rise from
// (see printed_h() / rise() in lib/common.scad).
//
// Chaise = "left"/"right" makes an L-shaped chaise sectional: the seat extends forward as
// a chaise at that end (the side it is on seen from the front, facing the back), with the
// one arm on the far end of the back run and the chaise left open — a lounge you put your
// legs up on. The L footprint is two footprint() rectangles unioned and its two magnet
// pockets are placed by hand, so the shared footprint()/magnets() stay rectangular-only.

include <../lib/common.scad>

Width  = 200;  // cm — a 3-seat sofa (150 loveseat, 240 large); back-run width for a chaise
Depth  = 90;   // cm — seat depth of the (back) run
Height = 85;   // cm — top of the back cushion
Arm    = 65;   // cm — top of the arms, lower than the back as on a real sofa
Seat   = 45;   // cm — seat height (top of the seat block the cushions rise from)

// L-shaped chaise sectional: "none" = straight sofa; "left"/"right" = a chaise
// extending forward at that end.
Chaise       = "none";
Chaise_depth = 160;  // cm — how far the chaise reaches forward (total front-to-back)
Chaise_width = 95;   // cm — width of the chaise leg, about one seat

// printed mm: the seat block the cushions stand on, and how far (cm) the back and the
// arms rise off it to reach Height / Arm
Seat_z = printed_h(Seat);
Pad_h  = Height - Seat;
Arm_h  = Arm - Seat;

Show_cushions = true;
// The cushions, in real-world cm. The back and each arm run edge to edge of the well
// between them; the seat is one soft cushion in that well with a seam line per seat.
Back_d    = 22;  // back cushion depth (front-to-back at its base)
Arm_w     = 20;  // arm cushion width (side-to-side)
Seat_rise = 11;  // cm the seat cushion stands proud of the seat block
Recline   = 12;  // cm the back's top edge leans back from its base — the recline
Seat_gap  = 4;   // cm left around the seat cushion, from the arms and the front edge
Back_gap  = 2;   // cm between two back cushions — a thin seam, so the back reads as one
Seat_span = 60;  // cm of run per seat, used to pick the seat count when Seats = 0
Seats     = 0;   // seats in the back run; 0 = one per Seat_span cm of it
// The seam line between two seats (see the header) — a shallow valley in the seat top.
Seam_w     = 1.6;  // mm printed width of a seam ...
Seam_depth = 1;    // ... and mm it is cut into the cushion

Show_pillows = true;
Pillow_size  = 40;  // cm side of a throw pillow (a diamond from above); shrinks to fit
Pillow_rise  = 22;  // cm it stands proud of the seat block — a plump lump, ~arm height
Pillows      = 2;   // how many, tossed against the back toward one side of the run

// Magnet pockets in the bottom face (0 = none). Two keep the piece from pivoting on the
// board; see Magnet_* in lib/common.scad.
Magnets = 2;

// ---- L geometry -------------------------------------------------------------
// The whole piece reaches Chaise_depth front-to-back when it has a chaise, else Depth.
function total_depth() = Chaise == "none" ? Depth : Chaise_depth;
// +1 puts the chaise on the right (+X), -1 on the left.
function chaise_sign() = Chaise == "right" ? 1 : -1;
// y-centre of the back run: its back edge sits at +total_depth/2.
function run_cy()    = total_depth() / 2 - Depth / 2;
// x-centre of the chaise leg, hard against the outer end.
function chaise_cx() = chaise_sign() * (Width / 2 - Chaise_width / 2);

// ---- seating wells ----------------------------------------------------------
// Each well is [cx, cy, w, d] in real cm — the patch of seat left once the arms, the
// back and a Seat_gap all round have had their share. The seat cushion, its seams and
// the back cushions over it are all sized from the same well, so they can never drift.
// The run's back edge is at +total_depth/2 whether it is straight or an L, so the back
// cushions share one rear line.
// A well's back edge butts the back cushion (no gap, so the seat runs into the back),
// while its front and sides are inset Seat_gap. The run is a straight or an L well; the
// chaise leg is one long well in front of the same shared back.
function run_front_y() =
    (Chaise == "none" ? -Depth / 2 : run_cy() - Depth / 2) + Seat_gap;
function run_seat() =
    let (fy = run_front_y(), by = back_rear() - Back_d)
    [ Chaise == "none" ? 0 : chaise_sign() * (Arm_w - Chaise_width) / 2,
      (fy + by) / 2,
      Chaise == "none" ? Width - 2 * Arm_w - 2 * Seat_gap
                       : Width - Arm_w - Chaise_width - 2 * Seat_gap,
      by - fy ];
// The chaise leg's lounge cushion — one long seat in front of the back, Chaise only.
function chaise_seat() =
    let (fy = -total_depth() / 2 + Seat_gap, by = back_rear() - Back_d)
    [ chaise_cx(), (fy + by) / 2, Chaise_width - 2 * Seat_gap, by - fy ];
// Seats in the run: one per Seat_span cm, or Seats if set.
function run_n() = Seats > 0 ? Seats : max(1, round(run_seat()[2] / Seat_span));
// The back's rear line, real cm — shared by every back cushion.
function back_rear() = total_depth() / 2;

sofa();

module sofa() {
    difference() {
        union() {
            carcass();
            if (Show_cushions) {
                seat_pad(run_seat());
                if (Chaise != "none") seat_pad(chaise_seat());
                back_cushions();
                arms();
                if (Show_pillows) pillows();
            }
        }
        if (Magnets > 0) sofa_magnets();
        if (Show_cushions) seams();
    }
}

// The seat block: a plain rectangle for a straight sofa, or an L (back run plus a
// forward chaise) for a sectional — two footprint() rectangles unioned, so the outer
// corners round and the inner corner stays square, like a real sectional.
module carcass() {
    if (Chaise == "none")
        footprint(Width, Depth, Seat_z);
    else
        union() {
            translate([0, cm(run_cy()), 0]) footprint(Width, Depth, Seat_z);
            translate([cm(chaise_cx()), 0, 0])
                footprint(Chaise_width, total_depth(), Seat_z);
        }
}

// One soft seat cushion filling a well [cx, cy, w, d], standing Seat_rise proud of the
// block. The seams (below) divide its flat top into seats.
module seat_pad(reg) {
    translate([cm(reg[0]), cm(reg[1]), 0])
        cushion(reg[2], reg[3], Seat_z, Seat_rise);
}

// The reclined back: one cushion per seat over the run, plus one over the chaise leg,
// each leaning back and split from its neighbour by Seat_gap so the seats read as
// separate cushions from the front.
module back_cushions() {
    reg = run_seat();
    n   = run_n();
    for (i = [0 : n - 1]) {
        cx = reg[0] - reg[2] / 2 + (i + 0.5) * reg[2] / n;
        w  = reg[2] / n - Back_gap;
        translate([cm(cx), 0, 0])
            backrest(w, Back_d, Seat_z, back_rear(), Pad_h, Recline);
    }
    if (Chaise != "none")
        translate([cm(chaise_cx()), 0, 0])
            backrest(Chaise_width - 2 * Seat_gap, Back_d, Seat_z, back_rear(),
                     Pad_h, Recline);
}

// The arms: one down each side of a straight sofa, or just the far end of a chaise
// sectional (its chaise stays open, as one you would put your legs up on).
module arms() {
    if (Chaise == "none")
        for (s = [-1, 1])
            translate([s * cm(Width / 2 - Arm_w / 2), 0, 0])
                cushion(Arm_w, Depth, Seat_z, Arm_h);
    else
        translate([-chaise_sign() * cm(Width / 2 - Arm_w / 2), cm(run_cy()), 0])
            cushion(Arm_w, Depth, Seat_z, Arm_h);
}

// The seam lines: a shallow groove between each pair of seats, cut into the flat top of
// the seat cushion. The run gets its n-1 divisions; a chaise gets one cross seam, so its
// long lounge cushion reads as a seat and an ottoman rather than one slab.
module seams() {
    reg = run_seat();
    n   = run_n();
    top = Seat_z + rise(Seat_rise);
    for (i = [1 : n - 1])
        groove(reg[0] - reg[2] / 2 + i * reg[2] / n, reg[1],
               plan_cm(Seam_w), reg[3], top, Seam_depth);
    if (Chaise != "none") {
        c = chaise_seat();
        // a cross seam near the front of the run, splitting seat from ottoman
        groove(c[0], run_cy() - Back_d / 2, c[2], plan_cm(Seam_w), top, Seam_depth);
    }
}

// Throw pillows, tossed against the back toward the middle of the run: each a diamond
// (a square cushion turned 45 deg), clamped to the seat so it never hangs off the edge,
// and shrunk if the well is too small for the size asked (an armchair-sized well). A
// pillow that still will not fit is dropped with a note rather than left poking out.
module pillows() {
    reg  = run_seat();
    // as many pillows as fit the run cleanly, up to Pillows, then a size that lets that
    // many sit side by side with a little air between (1.08) — so no size clamps or
    // overlaps into the crater two merged diamonds make
    n    = max(1, min(Pillows, floor(reg[2] / (Pillow_size * sqrt(2) * 1.08))));
    size = min(Pillow_size, reg[3] / sqrt(2), reg[2] / (n * sqrt(2) * 1.08));
    half = size * sqrt(2) / 2;                        // its reach from the centre
    step = size * sqrt(2) * 1.08;
    yp   = reg[1] + reg[3] / 2 - half;               // back tip against the back
    // tucked toward one side, but only as far as leaves the row clear of the arms
    side = Chaise == "none" ? 1 : -chaise_sign();
    cx0  = reg[0] + side * (reg[2] / 2 - half - (n - 1) * step / 2) * 0.6;
    if (size < Symbol_min)
        echo(str("NOTE: no room for a throw pillow on a ", reg[2], "x", reg[3],
                 " cm seat — dropped it"));
    else
        for (i = [0 : n - 1]) {
            x  = cx0 + (i - (n - 1) / 2) * step;
            xc = max(reg[0] - reg[2] / 2 + half, min(reg[0] + reg[2] / 2 - half, x));
            translate([cm(xc), cm(yp), 0]) pillow(size, Seat_z, Pillow_rise);
        }
}

// Magnet pockets. The shared magnets() rows along one axis of a rectangle, which is
// right for a straight sofa; for the L it cannot reach the chaise, so the two pockets
// are placed by hand — one under the back run near the arm, one under the chaise — far
// apart so the piece cannot pivot. A sofa is wide enough for the 4 mm disc everywhere,
// so magnet_pocket() takes the default.
module sofa_magnets() {
    if (Chaise == "none")
        magnets(Width, Depth, Magnets);
    else {
        magnet_pocket(cm(-chaise_sign() * Width / 4), cm(run_cy()));
        magnet_pocket(cm(chaise_cx()), 0);
    }
}
