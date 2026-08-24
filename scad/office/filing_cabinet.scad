// office / filing_cabinet — a pedestal of drawers token, with a drawer-fronts
// symbol engraved on top and nothing else.
//
// Width/Depth are the real-world footprint in cm: a filing-cabinet pedestal is
// narrow and deep, 40 wide by 55 deep, so a hanging file runs front-to-back.
// Height is the real carcass height — a three-drawer pedestal is built to slide
// under a desk top — shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad).

include <../lib/common.scad>

Width  = 40;  // cm
Depth  = 55;  // cm
Height = 72;  // cm — a pedestal, under a 74 cm desk top

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_drawers = true;
// Magnet pockets in the bottom face (0 = none). One central pocket: the piece
// is small enough that it does not need a second to stop it pivoting. The
// 40 cm width is 10 mm at 1:40 — wide enough for a 4 mm disc.
Magnets = 1;

filing_cabinet();

module filing_cabinet() {
    // the drawers get the whole top face, as big as they will fit; Width is
    // the tighter dimension, so the usable patch is squared off to it, the
    // same way table.scad squares a round top's patch to its inscribed square
    patch = min(cm(Width), cm(Depth)) - 2 * Symbol_margin;
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_drawers)
            drawers(drawers_size(patch, patch), Print_h, rows = 3);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
