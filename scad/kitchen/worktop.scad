// kitchen / worktop — a base-cabinet worktop run token, with vertical seams
// marking where adjacent cabinet fronts meet and a thin lip line just inside
// the front edge for the worktop's overhang. Plain rounded block, no
// legs/body split: a worktop sits flush on its base cabinets, so the token
// stays one flat slab.
//
// Width/Depth are the real-world footprint in cm: Depth is the standard 60 cm
// base-cabinet run; Width is modular — override to the standard run lengths
// 60, 80, 100 or 120 (all stay 60 cm deep). Height is the real worktop height —
// the standard 90 cm counter — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so every counter-height piece comes out level.

include <../lib/common.scad>

Width  = 120;  // cm — modular run length: 60, 80, 100 or 120 (all take Depth=60)
Depth  = 60;   // cm — standard base-cabinet depth
Height = 90;   // cm — standard worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// Cabinet fronts: a vertical seam every ~Front_unit cm across the run, plus a
// line just inside the front edge for the worktop's lip. The run's FRONT
// (where the fronts and the lip are) is the -Y edge; +Y is the wall side.
Show_fronts = true;
Front_unit  = 60;  // cm — target width of one cabinet front
Lip_inset   = 5;   // cm — how far inside the front edge the lip line sits
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the run from pivoting; a 60 cm depth is 15 mm at 1:40, plenty of room
// for a 4 mm disc (see Magnet_* in lib/common.scad).
Magnets = 2;

worktop();

module worktop() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_fronts) fronts(Print_h);
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// The run's cabinet fronts, cut into the top face: an interior seam at every
// unit boundary, spread evenly so a run that does not divide by Front_unit
// exactly comes out as equal-width fronts rather than one narrow leftover,
// plus a line just inside the front (-Y) edge that reads as the worktop's
// overhanging lip.
module fronts(top_z, depth = Label_depth) {
    units  = max(1, round(Width / Front_unit));
    unit_w = Width / units;
    stroke = Symbol_stroke * Scale / 10;  // cm that prints Symbol_stroke wide
    margin = Symbol_margin * Scale / 10;  // cm that prints Symbol_margin wide
    union() {
        for (i = [1 : units - 1])
            groove(-Width / 2 + i * unit_w, 0, stroke, Depth - 2 * margin,
                   top_z, depth);
        groove(0, -Depth / 2 + Lip_inset, Width - 2 * margin, stroke, top_z,
               depth);
    }
}
