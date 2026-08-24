// hallway / bench — an entryway seat token, with a shallow seat-pad outline and
// a lower shoe-shelf hint groove on top, or a raised cushion instead.
//
// Width/Depth are the real-world footprint in cm: a hallway bench runs the width
// of an entryway, seat-depth only (Depth stays 35, like the dining bench — just
// deep enough to sit on, too narrow for anything more). Height is the real seat
// height, shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad), so it comes out as low as a dining bench.
//
// +Y is the back of the bench (against the wall); -Y is the open front, under
// which a shoe shelf set back beneath the seat would peek out. That shelf is not
// modelled as a real step — just a hint groove near the front edge — so the
// piece stays one solid, support-free slab.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 35;   // cm
Height = 45;   // cm — seat height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// A shallow outline groove set in from the edge, hinting at the seat pad — drawn
// as four groove() edges (like a picture frame) rather than one filled cut, so it
// reads as a line and not a second footprint.
Show_seat_pad = true;
Pad_inset     = 4;  // cm the pad outline sits in from the edge

// A single groove near the front edge, hinting at a shoe shelf set back under
// the seat (not a real step — see the header note on printability).
Show_shelf  = true;
Shelf_inset = 2;  // cm the shelf line sits in from the front edge

// A raised seat cushion instead of the flat pad outline — off by default (a
// bench reads fine as a plain slab); sized to sit inside the pad outline, so the
// seam still shows around its base when both are on. See cushion() in
// lib/common.scad — it self-tapers, so it prints without support.
Show_cushion = false;

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
// The 35 cm depth is 8.75 mm across at 1:40 — wide enough for a 4 mm disc.
Magnets = 2;

bench();

module bench() {
    union() {
        difference() {
            footprint(Width, Depth, Print_h);
            if (Show_seat_pad)
                seat_pad(Print_h);
            if (Show_shelf)
                shelf_hint(Print_h);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_cushion)
            cushion(Width - 2 * Pad_inset, Depth - 2 * Pad_inset, Print_h);
    }
}

// The seat-pad outline: a rectangular rim inset from the edge, drawn as four
// groove() edges (top, bottom, left, right) instead of one filled cut, so it
// reads as a line around the pad and not a second footprint. The line is held to
// one nozzle width in printed mm, converted back to the real-world cm groove()
// takes, so it stays readable at any Scale.
module seat_pad(top_z, inset = Pad_inset) {
    stroke = Symbol_stroke * Scale / 10;  // one nozzle, back-converted to real cm
    hw = Width / 2 - inset;
    hd = Depth / 2 - inset;
    groove(0,   hd, 2 * hw + stroke, stroke, top_z);
    groove(0,  -hd, 2 * hw + stroke, stroke, top_z);
    groove(-hw,  0, stroke, 2 * hd + stroke, top_z);
    groove( hw,  0, stroke, 2 * hd + stroke, top_z);
}

// The shelf hint: a single groove line near the front edge (-Y), the width of
// the pad outline, standing in for a shoe shelf set back under the seat.
module shelf_hint(top_z, inset = Shelf_inset) {
    stroke = Symbol_stroke * Scale / 10;  // one nozzle, back-converted to real cm
    groove(0, -(Depth / 2 - inset), Width - 2 * Pad_inset, stroke, top_z);
}
