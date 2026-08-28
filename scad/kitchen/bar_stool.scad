// kitchen / bar_stool — a bar stool: a round seat up on a pedestal, waisted between a
// low foot and the seat it flares out to. In section, up the stool:
//
//       _______        the seat, a slab at the full diameter with its pad ring
//      \       /       engraved on top ...
//       |     |        ... a flare, at most 45 deg so it prints without support ...
//       |     |        ... the column ...
//       /     \        ... a cone down to ...
//      |_______|       ... the foot, with the magnet pocket in the middle of it
//
// It used to be a plain disc with a ring engraved on top — the same 8.75 mm circle from
// every side, and at 16 mm tall the blockiest piece in the room for its size. The
// footprint has not changed (foot and seat are both Diameter, so the plan still reads a
// 35 cm token), but the waist between them is what says stool rather than peg from a low
// angle, and the flare under the seat is what says the seat is a seat.
//
// It prints the right way up and support-free: the cone narrows on the way up, the flare
// leans out no more than 45 deg, and the pocket opens at the floor as everywhere else.
//
// Diameter is the real-world seat size in cm — a bar stool seat is a narrow round disc,
// commonly 30-40 cm across — and the foot spreads to the same circle, so it is also the
// footprint. Height is the real seat height: a bar stool puts the seat up at a raised
// worktop / breakfast bar, so it stands taller than a dining chair and is shrunk by the
// plan scale like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Diameter = 35;  // cm — the seat, and what the foot spreads to
Height   = 65;  // cm — seat height at a breakfast bar

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_seat = true;
// The seat slab, in real cm, and how far the column flares out into it: this share of
// the space above the cone is flare, the rest straight column (as in office/chair.scad).
Seat_h = 5;
Flare  = 0.35;
// The foot and the cone up out of it, in real cm. A real stool's foot is lower than
// this; the token's is as tall as the magnet pocket in it needs, or the pocket would
// break out through the side of the cone above it — the same allowance office/chair.scad
// makes on the width of its column (see foot_h()).
Foot_h = 5;
Cone_h = 6;
// The column, in real cm. A real gas lift is ~10 cm, which is 2.5 mm at 1:40 — thin
// enough to snap off in the box — so the token's is a little fatter than life.
Column_d = 14;

// Magnet pockets in the bottom face (0 = none). The foot is the same in every direction
// and the pocket sits dead centre of it, so one is all it can take and all it needs: a
// 35 cm foot is 8.75 mm across at 1:40, wide enough for the 4 mm disc (a smaller stool
// drops to the 2 mm one on its own — see Magnet_* in lib/common.scad).
Magnets = 1;

// The foot's real height in cm: what was asked for, but never so low that the pocket in
// it reaches up into the cone, where the piece is already narrower than the pocket is
// wide — rise_cm(magnet_pad_h()) is the pocket plus a little material over its ceiling,
// in the units the part is written in. Never more than a third of the stool either,
// whatever the numbers say. A stool with no magnets asks nothing of its foot.
function foot_h() =
    min(Height / 3,
        max(Foot_h, Magnets > 0 ? rise_cm(magnet_pad_h()) : 0));

bar_stool();

module bar_stool() {
    foot = rise(foot_h());
    seat = min(rise(Seat_h), (Print_h - foot) / 3);
    body = max(0, Print_h - foot - seat);            // cone + column + flare
    cone = min(rise(Cone_h), body * 0.4);
    rest = body - cone;                              // column + flare
    // The flare may not lean out more than 45 deg, so it is at least as tall as it is
    // wide. Where there is not room for that the column comes out fatter instead of the
    // slope steeper, the same cap office/chair.scad and diningroom/table.scad use.
    flare = min(rest, max(rest * Flare, (cm(Diameter) - cm(Column_d)) / 2));
    col   = max(cm(Column_d), cm(Diameter) - 2 * flare);
    difference() {
        union() {
            // the foot, and the cone narrowing out of it into the column
            footprint_round(Diameter, foot + 0.01);
            translate([0, 0, foot])
                cylinder(h = cone + 0.01, d1 = cm(Diameter), d2 = col);
            // the column, then the flare out to the full seat
            translate([0, 0, foot + cone])
                cylinder(h = rest - flare + 0.01, d = col);
            translate([0, 0, Print_h - seat - flare])
                cylinder(h = flare + 0.01, d1 = col, d2 = cm(Diameter));
            translate([0, 0, Print_h - seat]) footprint_round(Diameter, seat);
        }
        // a seat pad ring set in from the rim, as big as the top face allows
        if (Show_seat)
            pad(Print_h);
        if (Magnets > 0)
            magnets(Diameter, Diameter, Magnets);
    }
}

// The seat pad, cut into the top face at the same depth as label() — a single
// stroke_arc traced just inside the rim, kept Symbol_margin off the edge and
// Symbol_stroke wide, centred on the origin.
module pad(top_z, depth = Label_depth) {
    r = cm(Diameter) / 2 - Symbol_margin - Symbol_stroke / 2;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            stroke_arc(r, 0, 360, Symbol_stroke);
}
