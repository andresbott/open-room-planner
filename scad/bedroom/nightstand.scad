// bedroom / nightstand — a bedside-table token: a bank of drawer fronts filling
// the top inside a slim top-edge reveal, each front carrying a round knob, so it
// reads as a real bedside chest from above and not as a shrunken chest of drawers.
//
// Width/Depth are the real-world footprint in cm: bedside tables run 40..60 wide
// (the Makefile builds those), 40 deep. Height is the real top height — a bedside
// top sits about level with the mattress it stands next to — shrunk by the plan
// scale like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 40;  // cm
Depth  = 40;  // cm
Height = 55;  // cm — about mattress height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_drawers = true;
// How many drawer fronts fill the top. Auto by depth — a shallow bedside gets a
// single drawer, a normal-depth one a pair — but override to pin a count.
Drawers     = Depth < 32 ? 1 : 2;
Front_inset = 3;   // cm of top left showing around the drawer bank (the reveal)
// Bedside tops this wide (cm) get two knobs per drawer instead of one central one.
Knob_pair_from = 55;
Knob_d = 1.4;  // printed mm, the knob dimple — drawing detail, so it does not scale

// Magnet pockets in the bottom face (0 = none). Small and near-square, so one
// central pocket holds it down. At 1:40 a 40 cm side is 10 mm across —
// comfortably wide enough for a 4 mm disc.
Magnets = 1;

nightstand();

module nightstand() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_drawers)
            drawer_fronts(Print_h, Drawers);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The drawer bank cut into the top face: a rectangular reveal inset from the edge,
// split into <rows> fronts by horizontal seams, each front carrying a knob (a pair
// when the piece is wide). The reveal and seam lines are held to one nozzle width
// in printed mm, converted back to the real cm groove() takes, so they stay
// readable at any Scale; the knob is a printed-mm dimple — drawing detail like the
// symbols, so it keeps its size at any scale. Subtract it like the symbols:
//   difference() { footprint(40, 40, 4); drawer_fronts(4, 2); }
module drawer_fronts(base_z, rows = Drawers, inset = Front_inset,
                     pair_from = Knob_pair_from, knob_d = Knob_d) {
    stroke = Symbol_stroke * Scale / 10;   // one nozzle, back to real cm (see bench)
    hw  = Width / 2 - inset;               // half the drawer-bank width, cm
    hd  = Depth / 2 - inset;               // half the drawer-bank depth, cm
    top = base_z;                          // the cuts land on the top face
    k   = Width >= pair_from ? 2 : 1;      // knobs per drawer front
    union() {
        // the reveal: a rectangle inset from the edge, drawn as four seam lines so
        // it reads as a line around the drawer bank and not a second footprint
        groove(0,   hd, 2 * hw + stroke, stroke, top);
        groove(0,  -hd, 2 * hw + stroke, stroke, top);
        groove(-hw,  0, stroke, 2 * hd + stroke, top);
        groove( hw,  0, stroke, 2 * hd + stroke, top);
        // the seams between fronts, evenly spaced front-to-back
        for (i = [1 : rows - 1])
            groove(0, -hd + i * 2 * hd / rows, 2 * hw, stroke, top);
        // a knob on each front — centred, or a pair spread across a wide top
        for (r = [0 : rows - 1]) {
            fy = -hd + (r + 0.5) * 2 * hd / rows;          // centre of this front, cm
            for (j = [0 : k - 1]) {
                fx = k == 1 ? 0 : (j - (k - 1) / 2) * hw;  // ±hw/2 for a pair
                translate([cm(fx), cm(fy), top - Label_depth])
                    cylinder(h = Label_depth + 0.01, d = knob_d);
            }
        }
    }
}
