// outdoor / table — a garden table with a slatted top, round or square: a thin top slab at
// the full footprint standing on four real legs with the air of a table under it
// (slab_on_legs() in lib/common.scad), square tops on corner legs and round ones on four legs
// round the rim, which is where a garden table's are.
//
// It used to have a sloped body set back from the edge instead — a solid taper that stood in
// for the space under a table because a slab bridging between open legs cannot print upright.
// It does not have to: PRINT IT FACE DOWN, top face on the bed, and the legs only ever rise
// from the widest face, so nothing overhangs and nothing bridges (the same trade
// diningroom/table.scad and office/desk.scad make). The magnet pockets open upwards in the
// feet for the discs to drop into; the model itself stays the right way up, so flip it in the
// slicer.
//
// Grooved seams across the top read as timber decking slats rather than a place setting, so
// the piece is not mistaken for the dining table indoors — that and the legs, which a round
// dining table does not have (it gets a pedestal).
//
// Width/Depth (or Diameter, for a round top) are the real-world top in cm, and
// Height the real height of that top — garden-table height — shrunk by the plan
// scale like the footprint (see printed_h() in lib/common.scad), the same as
// diningroom/table.scad.

include <../lib/common.scad>

Round    = false;  // true -> a round top of Diameter; Width/Depth are ignored
Width    = 80;     // cm
Depth    = 80;     // cm
Diameter = 90;     // cm, round tops only
Height   = 74;     // cm — garden-table height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top slab, in real cm — the only part of the token at full footprint, so its
// edge is the line you read the size off. At 8 cm (2 mm printed) it has the body to survive
// printing face down and handling; a 4 cm top came off the bed as a fragile 1 mm sheet.
Top_h = 8;
// A leg, in real cm. A real garden-table leg is about 7 cm, which is 1.75 mm at 1:40 and
// nothing a magnet could live in, so the token's is as wide as the pocket in its foot needs —
// clamped up to that by slab_leg() in lib/common.scad, the same allowance the dining table and
// the desk make.
Leg       = 7;
Leg_inset = 2;   // cm the legs are set in from the edge, so the top stands proud of them
Gap_min   = 20;  // cm of clear span that must be left between two legs

// Parallel grooves across the top, standing in for the seams between decking
// boards. Slat_pitch is the real-world seam-to-seam spacing (one board's width);
// Slat_groove is how wide each seam is cut — 2 cm here is 0.5 mm printed, a hair
// over one nozzle, as a symbol stroke is; Slat_margin keeps the outermost seams off
// the rim (and clear of a rounded corner).
Show_slats  = true;
Slat_pitch  = 9;   // cm
Slat_groove = 2;   // cm
Slat_margin = 6;   // cm

// Magnet pockets in the bottom face (0 = none) — one per FOOT, in diagonal order, so the two a
// table takes sit corner to opposite corner and cannot let the piece tilt or pivot; four is one
// in every foot. See slab_leg_pockets() and Magnet_* in lib/common.scad.
Magnets = 2;

// A leg and the clear span it leaves, both real cm — the shared slab-on-legs clamps, which put
// a magnet pocket's own minimum first. A table with no magnets asks nothing of its legs.
function min_span_cm() = Magnets > 0 ? magnet_span_cm() : 0;
function top_w()   = Round ? Diameter : Width;
function top_d()   = Round ? Diameter : Depth;
function leg_w()   = slab_leg(top_w(), top_d(), Leg, min_span_cm(), Leg_inset, Gap_min);
function leg_gap() = slab_leg_gap(top_w(), top_d(), leg_w(), Leg_inset);

table();

module table() {
    if (leg_gap() < Gap_min - 0.001)
        echo(str("NOTE: an ", top_w(), "x", top_d(), " cm top at 1:", Scale, " leaves ",
                 leg_gap(), " cm between legs a magnet fits in, under the ", Gap_min,
                 " cm asked for — the legs are crowding out the air they are there to show"));
    difference() {
        slab_on_legs(top_w(), top_d(), Print_h, leg_w(), Top_h,
                     round = Round, inset_cm = Leg_inset) top_2d();
        if (Show_slats)
            slats(Print_h);
        if (Magnets > 0)
            slab_leg_pockets(top_w(), top_d(), leg_w(), Magnets,
                             round = Round, inset_cm = Leg_inset);
    }
}

// The outline of the top — everything else is built from it.
module top_2d() {
    if (Round) footprint_round_2d(Diameter);
    else       footprint_2d(Width, Depth);
}

// Parallel seams across the top, standing in for the gaps between decking
// boards, spaced Slat_pitch cm apart and kept Slat_margin cm off the rim — the
// same spread-with-margin idea as magnets(). Each line is cut as wide as the top
// itself; on a round top that overshoots the chord at that seam, but a groove
// only removes material where there is some, so it is clipped for free by the
// disc outline. Subtract it from the top face like groove():
//   difference() { footprint(80, 80, 6); slats(6); }
module slats(top_z, depth = Label_depth) {
    w      = Round ? Diameter : Width;
    d      = Round ? Diameter : Depth;
    usable = d - 2 * Slat_margin;
    n      = max(1, floor(usable / Slat_pitch) + 1);
    span   = (n - 1) * Slat_pitch;
    for (i = [0 : n - 1]) {
        y = n > 1 ? -span / 2 + i * Slat_pitch : 0;
        groove(0, y, w, Slat_groove, top_z, depth);
    }
}
