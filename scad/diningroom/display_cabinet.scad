// diningroom / display_cabinet — a glass-fronted china/display cabinet token,
// with a glazed door seam and a light grid of shelf lines engraved on top and
// nothing else.
//
// Width/Depth are the real-world footprint in cm: a 100 cm-wide, 40 cm-deep
// cabinet — narrower and shallower than a wardrobe, sized to show off china
// rather than hang clothes. Height is the real carcass height — a display cabinet
// stands about as tall as a wardrobe — shrunk by the plan scale like the footprint
// (see printed_h() in lib/common.scad); the glazed grid (not a hanger or open
// shelves) is what tells it apart.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 40;   // cm
Height = 200;  // cm — full-height carcass

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_doors = true;
// Two hinged glass doors meeting at a centre seam, crossed by evenly spaced
// shelf lines — the seam alone would read as a wardrobe, the lines alone as
// open shelving; together they read as a light grid of small glazing panes,
// with the shelves inside showing through. Real-world cm, like groove()'s own
// arguments.
Door_margin = 4;  // cm kept clear at every edge of the glazed area
Seam_w      = 2;  // cm — seam/shelf-line width (0.5 mm printed at 1:40)
Shelf_lines = 3;  // horizontal lines crossed over the doors (4 shelves implied)

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad. The 40 cm
// depth is 10 mm across at 1:40 — comfortably wide enough for a 4 mm
// disc.
Magnets = 2;

display_cabinet();

module display_cabinet() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_doors) doors(Print_h);
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// The glazed front: one vertical seam where the two doors meet, crossed by a
// few horizontal lines standing in for the shelves visible through the glass.
module doors(top_z, margin = Door_margin, w = Seam_w, rows = Shelf_lines) {
    inner_w = Width - 2 * margin;
    inner_d = Depth - 2 * margin;
    union() {
        groove(0, 0, w, inner_d, top_z);          // where the two doors meet
        for (i = [1 : rows])
            groove(0, -inner_d / 2 + i * inner_d / (rows + 1), inner_w, w,
                   top_z);
    }
}
