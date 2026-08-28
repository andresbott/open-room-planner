// bedroom / bench — a bed-end bench printed as a U: a plain seat slab at the full
// footprint, carried at each end by a panel that runs straight down FLUSH with the
// edge of the seat, with nothing between them. Cut it across the width and the piece
// is a U — slab plus two legs, open front and back — so the sides read as open space
// under the seat and not as a lidded box. No cushion, no pad: the seat is a flat top
// face, and the U underneath is what says bench.
//
// This is why it is a U and not the dining table's sloped apron (see
// diningroom/table.scad): the piece is printed UPSIDE DOWN, seat face on the bed.
// That way the void under the slab opens upward, so there is nothing to bridge and
// nothing overhangs; the magnet pockets come out as open holes in the top of the two
// standing panels; and the seat — the face you read the size off — is the first layer
// against the glass. The model itself stays the right way up like every other part
// (pockets at z = 0, in the bottom face); flip it in the slicer.
//
// Flip Show_lid on and the piece closes up into a plain solid slab carrying a lid
// seam instead — a storage bench / blanket box, which is a box and prints either way
// up.
//
// Width is the real-world footprint in cm: a bed-end bench runs 100 to 160 wide to
// match the bed it sits against (the branded IKEA EKENÄSET is 112 x 48). Depth is
// the seat depth, 40 for the plain benches. Height is the real seat height — the
// surface you sit on — shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad), so a bench comes out about as low as a bed.

include <../lib/common.scad>

Width  = 120;  // cm — 100..160 to match the bed it sits against (EKENÄSET: 112)
Depth  = 40;   // cm — a bench's seat depth (EKENÄSET: 48)
Height = 45;   // cm — seat height, the surface you sit on

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The two legs of the U. Side is the real thickness of an end panel and Top the real
// thickness of the seat slab spanning between them — both are floored in printed mm,
// because both carry hardware or bridge a void:
//   Side  is raised to what a magnet pocket needs across (magnet_min_span — 6.3 mm
//         for the standard disc, so 25 cm at 1:40), the same way the dining table's
//         footing is: the panel feet are the only material left at floor level, so
//         they are where the magnets go.
//   Top   keeps at least Top_min of material over the void, so the slab is a few
//         solid layers on the bed rather than a skin.
// A bench too narrow to leave a usable opening between the panels just prints solid,
// and says so.
Side     = 12;   // cm — end panel, floored by the magnet pocket it has to hold
Top      = 8;    // cm — seat slab over the void
Top_min  = 1.2;  // mm — least material over the void, printed (a print detail)
Void_min = 1.2;  // mm — smallest opening worth leaving; below it, print solid

// A storage bench / blanket box instead: a plain solid slab (no panels, no void)
// carrying the seam of a hinged lid — a rim inset from the edge, drawn as four
// grooves so it reads as a line and not a second footprint. Off by default.
Show_lid  = false;
Lid_inset = 3;   // cm the lid seam sits in from the edge

// Magnet pockets in the bottom face (0 = none). On the U they can only go where
// there is material at floor level: one in the foot of each end panel, so 2 is the
// pair and 1 puts a single pocket under the left-hand panel. See Magnet_* in
// lib/common.scad. At 1:40 the 40 cm depth is 10 mm across, comfortably wide enough
// for a 4 mm disc, and Side is held to the 6.3 mm the pocket needs the other way.
Magnets = 2;

bench();

module bench() {
    // a U-section bench, or — with Show_lid — a plain lidded box
    if (Show_lid) box();
    else          frame();
}

// The U: a seat slab at the full footprint standing on an end panel at each end,
// both flush with the edge, and the space between them cut clean away front to back.
// The magnets go in the panel feet, the only material left at the floor.
module frame() {
    mag_d  = magnet_d_for(Width, Depth);
    // an end panel is at least as thick as a pocket needs across, as the dining
    // table's footing is (see table.scad) — the feet are what hold the magnets
    side   = max(cm(Side), magnet_min_span(mag_d));
    top    = min(max(cm(Top), Top_min), Print_h);
    gap    = cm(Width) - 2 * side;   // the opening between the panels
    void_h = Print_h - top;          // ... and how far it reaches up under the slab
    hollow = gap >= Void_min && void_h >= Void_min;
    if (cm(Side) < side)
        echo(str("NOTE: ", Side, " cm end panels at 1:", Scale, " are thinner than a ",
                 mag_d, " mm pocket needs — printed as ", plan_cm(side), " cm"));
    if (!hollow)
        echo(str("NOTE: ", Width, "x", Depth, " cm at 1:", Scale,
                 " leaves no room under the seat for a U — printed solid"));
    difference() {
        footprint(Width, Depth, Print_h);
        if (hollow)
            void(gap, void_h);
        if (Magnets > 0)
            feet_magnets(side, mag_d);
    }
}

// The space under the seat: a straight cut <w> mm wide and <h> mm tall, running the
// whole depth so it is open at the front and the back — the inside of the U. Square
// inner faces, so only the outer corners of the piece stay rounded.
module void(w, h) {
    translate([0, 0, h / 2 - 0.005])
        cube([w, cm(Depth) + 1, h + 0.01], center = true);
}

// A pocket in the foot of each end panel — centred in a panel <side> mm thick, which
// is the whole of the piece that touches the board. Placed by hand rather than with
// magnets(): that spreads a row along the width, and on a U the middle of the width
// is thin air.
module feet_magnets(side, mag_d) {
    count  = min(Magnets, 2);
    foot_x = (cm(Width) - side) / 2;
    fits   = cm(Depth) >= magnet_min_span(mag_d);
    if (Magnets > count)
        echo(str("WARNING: a U bench has 2 feet — cutting ", count, " of ", Magnets,
                 " magnets"));
    if (!fits)
        echo(str("WARNING: ", Depth, " cm deep at 1:", Scale, " is too narrow for a ",
                 mag_d, " mm pocket — no magnets cut"));
    else
        for (i = [0 : count - 1])
            magnet_pocket(i == 0 ? -foot_x : foot_x, 0, mag_d, magnet_h_for(mag_d));
}

// A storage bench / blanket box: a plain solid slab at the full footprint carrying
// the lid seam. No panels and no void — a box sits flat on the floor.
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
