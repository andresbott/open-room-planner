// livingroom / coffee_table — a low, chunky coffee table built as a CUBE, not a scaled-down
// dining table: a solid block with a thick top, standing on a solid base, with one big OPEN SHELF
// cut into the front for books and the remote. Where the dining table is a thin top on four
// spindly legs with air all round, this is a solid, blocky thing — the mass and the single deep
// shelf are the point, so it reads as a modern cube from across the room, never as a small table.
//
// The shelf is a real open recess, not an engraved line: a bay cut into the front (−Y) face
// between two side walls, under the top slab and over the base, back to a panel that keeps the +Y
// side solid so the piece butts a sofa. That recess is a short ceiling — the underside of the top
// over a shelf a little over half the depth — so it prints UPRIGHT with nothing to bridge in
// mid-air and nothing to support. The base is left solid and broad: it is what the magnet pockets
// sink into, and what makes the piece sit like a block rather than perch like a table.
//
// Width/Depth are the real-world top in cm and Height the real height — a coffee table sits low,
// about 40 cm, chunky and square-ish (100x55 rectangular, 70x70 a cube), shrunk by the plan scale
// (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 55;   // cm
Height = 40;   // cm — low, a coffee table

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_shelf = true;
// The slabs the block divides into, in real cm. The base is deep enough to bury a magnet pocket
// and keep material over it; the top is a chunky surface; the sides frame the shelf.
Top_h  = 10;   // cm — the thick top slab (the table surface)
Base_h = 16;   // cm — the solid base under the shelf (buries the magnets, sits like a block)
Side_w = 12;   // cm — the side wall each side of the shelf
Back_w = 20;   // cm — the back panel behind the shelf (keeps the +Y side solid, shelf depth printable)

// Magnet pockets in the bottom face, a row along the width (0 = none). Two keep the piece from
// pivoting; they sink into the solid base — the whole footprint (see Magnet_* in lib/common.scad).
Magnets = 2;

coffee_table();

module coffee_table() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_shelf) shelf();
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// The open shelf: one bay cut into the front (−Y) face, between the two side walls, from the top
// of the base up to the underside of the top slab, back to Back_w short of the +Y face. A recess
// in a vertical face — a short ceiling that prints without support (see the header). Clamped: if
// the top/base/sides leave no room, the block is left solid and the render log says so.
module shelf() {
    w = Width - 2 * Side_w;
    h = Print_h - rise(Top_h) - rise(Base_h);
    if (w > 0 && h > 0) {
        y_front = -cm(Depth) / 2 - 0.1;
        y_back  =  cm(Depth) / 2 - cm(Back_w);
        if (y_back > y_front)
            translate([0, (y_front + y_back) / 2, rise(Base_h) + h / 2])
                cube([cm(w), y_back - y_front, h], center = true);
    } else {
        echo(str("NOTE: a ", Width, "x", Height, " cm coffee table leaves no room for a shelf ",
                 "between its ", Top_h, "/", Base_h, " cm top and base — left solid"));
    }
}
