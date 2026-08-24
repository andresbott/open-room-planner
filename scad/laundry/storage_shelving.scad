// laundry / storage_shelving — open storage shelving / utility racking token,
// with four shelf lines engraved on top and nothing else.
//
// Width/Depth are the real-world footprint in cm: open shelving/utility racking
// for a laundry or utility room commonly runs 80 wide and 40 deep. Height is its
// real height — racking is built as tall as the room allows — shrunk by the plan
// scale like the footprint (see printed_h() in lib/common.scad), so it stands with
// the tallest pieces of the set.

include <../lib/common.scad>

Width  = 80;   // cm
Depth  = 40;   // cm
Height = 180;  // cm — open racking, up past head height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_shelves = true;
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad. The 40 cm depth
// is only 10 mm at 1:40 — still room for the 4 mm disc with a wall either side,
// and a shallower shelf drops to the 2 mm one on its own.
Magnets = 2;

storage_shelving();

module storage_shelving() {
    difference() {
        footprint(Width, Depth, Print_h);
        // more rows than a chest of drawers, so the stacked fronts read as open
        // shelves instead of drawers — the symbol gets the whole top face
        if (Show_shelves)
            drawers(drawers_size(cm(Width) - 2 * Symbol_margin,
                                  cm(Depth) - 2 * Symbol_margin), Print_h, rows = 4);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
