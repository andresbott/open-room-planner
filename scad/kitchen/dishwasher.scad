// kitchen / dishwasher — an integrated dishwasher token (single front, no
// separate door line), with a slim control-panel groove and a short handle
// groove engraved near the front edge and nothing else.
//
// Width/Depth are the real-world footprint in cm: a standard full-size
// dishwasher is 60x60. Height is its real height — an integrated machine slides
// under a 90 cm worktop, so its own carcass is 82 cm — shrunk by the plan scale
// like the footprint (see printed_h() in lib/common.scad).
//
// The front is the -Y edge (the piece can be rotated on the board; this just
// fixes which edge the two grooves sit near). Kept deliberately spare — two
// plain groove() lines — so it reads differently from a cooker's hob rings at
// a glance.

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 60;  // cm
Height = 82;  // cm — the carcass, under a 90 cm worktop

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_front = true;
// Control-panel groove: a slim strip almost the full width, close to the
// front edge — the only visible give-away of an integrated dishwasher above
// the counter line. Real-world cm, measured from the front edge/centre.
Panel_margin = 4;   // gap from the front edge to the groove, cm
Panel_inset  = 8;   // gap left/right of the groove, cm
Panel_h      = 2;   // groove thickness (front-to-back), cm — 0.5 mm printed
// Handle groove: a short bar centred on the front, a little further back —
// the recessed grip under the panel. Real-world cm.
Handle_w     = 18;  // cm
Handle_h     = 2;   // cm
Handle_gap   = 3;   // gap behind the panel groove, cm
// Magnet pockets in the bottom face (0 = none). Near-square, so one central
// pocket holds it down; at 1:40 a 60 cm side is 15 mm across — comfortably
// wide enough for the 4 mm disc.
Magnets = 1;

dishwasher();

module dishwasher() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_front) front();
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// The two front-face grooves, stacked front-to-back near the -Y edge.
module front() {
    panel_y  = -Depth / 2 + Panel_margin + Panel_h / 2;
    handle_y = panel_y + Panel_h / 2 + Handle_gap + Handle_h / 2;
    union() {
        groove(0, panel_y, Width - 2 * Panel_inset, Panel_h, Print_h);
        groove(0, handle_y, Handle_w, Handle_h, Print_h);
    }
}
