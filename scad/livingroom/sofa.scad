// livingroom / sofa — a multi-seat token: a raised back cushion running the
// full width along the rear edge and an arm cushion down each short side, the
// multi-seat sibling of the armchair. Set Chaise for an L-shaped sectional.
//
// Width picks the size of a straight sofa: about 150 cm for a 2-seat loveseat,
// 200 for a 3-seat, 240 for a large one (IKEA-ish proportions); Depth is the
// overall seat depth, back cushion included. Both are real-world cm, and so are
// the two heights: Height is the top of the back — how tall the sofa is — and
// Seat the seat it rises from. The block is the seat; the back and arm cushions
// stand the rest on top of it (see printed_h() / rise() in lib/common.scad).
//
// Chaise = "left"/"right" makes an L-shaped chaise sectional: the seat extends
// forward as a chaise at that end (the side the chaise is on as seen from the
// front, facing the back cushion), with the one arm on the far end of the back
// run and the chaise left open — the silhouette of a chaise sectional. The L
// footprint is two footprint() rectangles unioned and its two magnet pockets are
// placed by hand, so the shared footprint()/magnets() stay rectangular-only.

include <../lib/common.scad>

Width  = 200;  // cm — a 3-seat sofa (150 loveseat, 240 large); back-run width for a chaise
Depth  = 90;   // cm — seat depth of the (back) run
Height = 85;   // cm — top of the back cushion
Arm    = 65;   // cm — top of the arms, lower than the back as on a real sofa
Seat   = 45;   // cm — seat height

// L-shaped chaise sectional: "none" = straight sofa; "left"/"right" = a chaise
// extending forward at that end.
Chaise       = "none";
Chaise_depth = 160;  // cm — how far the chaise reaches forward (total front-to-back)
Chaise_width = 95;   // cm — width of the chaise leg, about one seat

// printed mm: the seat block the cushions stand on, and how far (cm) the back and
// the arms rise off it to reach Height / Arm
Seat_z = printed_h(Seat);
Pad_h  = Height - Seat;
Arm_h  = Arm - Seat;

Show_cushions = true;
// Back and arm cushions, in real-world cm — unlike the armchair's, these run
// edge to edge: the back spans the full width and each arm the full depth, so
// the pads read as one wraparound seat back rather than three separate pillows.
Back_d = 22;  // back cushion depth (front-to-back)
Arm_w  = 20;  // arm cushion width (side-to-side)

// Magnet pockets in the bottom face (0 = none). Two keep the piece from pivoting
// on the board; see Magnet_* in lib/common.scad.
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

sofa();

module sofa() {
    union() {
        difference() {
            carcass();
            if (Magnets > 0) sofa_magnets();
        }
        if (Show_cushions) cushions();
    }
}

// The seat block: a plain rectangle for a straight sofa, or an L (back run plus a
// forward chaise) for a sectional — two footprint() rectangles unioned, so the
// outer corners round and the inner corner stays square, like a real sectional.
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

// The cushions: a back cushion full width along the rear edge, and the arms — one
// down each side of a straight sofa, or just the far end of a chaise sectional
// (its chaise stays open, as one you would put your legs up on).
module cushions() {
    translate([0, cm(total_depth() / 2 - Back_d / 2), 0])
        cushion(Width, Back_d, Seat_z, Pad_h);
    if (Chaise == "none")
        for (s = [-1, 1])
            translate([s * cm(Width / 2 - Arm_w / 2), 0, 0])
                cushion(Arm_w, Depth, Seat_z, Arm_h);
    else
        translate([-chaise_sign() * cm(Width / 2 - Arm_w / 2), cm(run_cy()), 0])
            cushion(Arm_w, Depth, Seat_z, Arm_h);
}

// Magnet pockets. The shared magnets() rows along one axis of a rectangle, which
// is right for a straight sofa; for the L it cannot reach the chaise, so the two
// pockets are placed by hand — one under the back run near the arm, one under the
// chaise — far apart so the piece cannot pivot. A sofa is wide enough for the 4 mm
// disc everywhere, so magnet_pocket() takes the default.
module sofa_magnets() {
    if (Chaise == "none")
        magnets(Width, Depth, Magnets);
    else {
        magnet_pocket(cm(-chaise_sign() * Width / 4), cm(run_cy()));
        magnet_pocket(cm(chaise_cx()), 0);
    }
}
