// bedroom / ikea_pax — an IKEA PAX wardrobe frame: an open bay cut into the front (-Y) face
// with the shelf and the clothes rail left standing across it as ribs, and the hanger
// engraved on the top. The size is in the file name: a 50 cm-wide frame is only 12.5 mm
// across at 1:40, too narrow for a readable one.
//
// A PAX is sold as a FRAME — no doors, one shelf near the top and a rail under it — and that
// open front is the whole difference between it and the sliding wardrobe standing next to it
// (bedroom/wardrobe.scad, whose leaves sit on two tracks). The token used to say so with the
// hanger pictogram alone, on its top face; now the bay is real, so the frame reads as open
// from a low angle and the hanger is just the label on the lid.
//
// The bay is a shallow recess and not a compartment cut through to a back panel the way
// livingroom/bookshelf.scad does its shelves. That part prints on its BACK so its dividers
// come out as vertical walls; a PAX frame is a 59 mm tower and better off printed upright,
// which means every rib across the bay has to be a ledge the printer can carry — so the bay
// is sunk Bay_in and no further, and the ribs come out the same 2 mm ledges the china
// cabinet's shelves do (diningroom/display_cabinet.scad).
//
// Width/Depth are the real-world frame size in cm (PAX comes 50, 75 or 100 wide, 58 or 35
// deep) and Height its real height — the tall 236 cm frame, or 201 for the short one. All
// three are shrunk by the plan scale (see printed_h() in lib/common.scad), so a PAX frame is
// one of the tallest pieces of the set.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 58;   // cm
Height = 236;  // cm — the tall frame (201 for the short one)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_bay = true;
// The open bay, in real cm: the carcass left standing round it, and how far into the front
// it is sunk.
Frame     = 4;   // cm of side panel left at each end ...
Base      = 14;  // ... of base under it (see base_h(): it also holds the magnet) ...
Top_panel = 8;   // ... and of top panel over it
Bay_in    = 8;   // cm the bay is sunk into the front face (not the library's Bay_depth:
                 // a frame is deeper than a cabinet's shelf recess)
// The shelf and the rail, in real cm. A PAX carries one shelf near the top with the clothes
// rail hung under it; below that the bay is the full hanging height.
Shelf_h    = 0;   // cm off the floor of the shelf (0 = Height - Shelf_drop)
Shelf_drop = 36;  // cm below the top of the frame the shelf sits, when derived
Rail_drop  = 10;  // cm below the shelf the rail hangs
Rib        = 2;   // cm — a shelf or rail rib, left standing at the face

Show_hanger = true;
// Magnet pockets in the bottom face, in a row along the width (0 = none). A 35 cm-deep frame
// is 8.75 mm across at 1:40 — wide enough for a 4 mm disc. One is enough on the narrow
// frames; the 100 cm-wide ones are 25 mm long and take two, so they cannot pivot on the plan
// (the Makefile asks for them).
Magnets = 1;

// ---- what fits in the frame -------------------------------------------------
// The base, in real cm: what was asked for, but never so low that the magnet pocket in it
// reaches up into the bay above — rise_cm(magnet_pad_h()) is the pocket plus a little
// material over its ceiling, in the units the part is written in.
function base_h() =
    min(Height / 3, max(Base, Magnets > 0 ? rise_cm(magnet_pad_h()) : 0));
// The top of the bay, and the shelf inside it: derived from the frame's own height so the
// tall and the short frame both come out right, and clamped into the bay either way.
function bay_top()  = Height - Top_panel;
function shelf_z()  = max(base_h() + Rib,
                          min(bay_top() - Rib,
                              Shelf_h > 0 ? Shelf_h : Height - Shelf_drop));
// The rail hangs under the shelf; on a frame too short for both it gives way to the shelf.
function rail_z()   = max(base_h(), shelf_z() - Rail_drop - Rib);

ikea_pax();

module ikea_pax() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_bay) bay();
        // the hanger gets the whole top face, as big as it will fit
        if (Show_hanger)
            hanger(hanger_size(cm(Width) - 2 * Symbol_margin,
                               cm(Depth) - 2 * Symbol_margin), Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The open bay: three recesses stacked up the front — the hanging space, the gap between the
// rail and the shelf, and the top compartment over it — with the rail and the shelf left
// standing at the face between them. Subtract it.
module bay() {
    w = cm(Width - 2 * Frame);
    if (w < Symbol_stroke)
        echo(str("WARNING: a ", Width, " cm frame at 1:", Scale,
                 " is too narrow for a bay — left solid"));
    else {
        shelf(rise(base_h()), rise(rail_z()), w);                    // the hanging space
        shelf(rise(rail_z() + Rib), rise(shelf_z()), w);             // rail to shelf
        shelf(rise(shelf_z() + Rib), rise(bay_top()), w);            // the top compartment
    }
}

// One compartment of the bay: a recess <w> wide spanning printed-mm heights <z0>..<z1>, sunk
// Bay_in into the front face. Anything too short to cut is left as solid carcass, which is
// what happens to the rail gap on a squashed set.
module shelf(z0, z1, w) {
    if (z1 - z0 > Symbol_stroke)
        front_recess(0, (z0 + z1) / 2, w, z1 - z0, Depth, cm(Bay_in));
}
