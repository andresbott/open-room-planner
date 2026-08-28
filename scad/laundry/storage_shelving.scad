// laundry / storage_shelving — open utility racking: a stack of real open bays cut into the
// front (-Y) face with the shelves left standing across them as ribs (front_bays() in
// lib/common.scad).
//
// It used to carry the drawers() pictogram on its top face with the row count turned up, in
// the hope that four stacked rectangles would read as shelves rather than as drawers. On a
// piece 20 x 10 mm on the plan and 45 mm up the front, they read as neither. The bays are
// real now, so the racking is the one thing it has to be — open — and it is told from the
// laundry's boxes (a washer, a dryer, their tower) by having no front at all rather than by a
// symbol.
//
// The bays are a recess and not a compartment cut through to the back, for the reason
// front_bays() gives: a rib across a shallow bay is a ledge the printer carries, while one
// across a through-cut is a bridge. That is the trade the open bookshelf makes the other way
// (livingroom/bookshelf.scad, which prints on its back to get real full-depth shelves).
//
// Width/Depth are the real-world footprint in cm: open shelving/utility racking for a laundry
// or utility room commonly runs 80 wide and 40 deep. Height is its real height — racking is
// built as tall as the room allows — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so it stands with the tallest pieces of the set.

include <../lib/common.scad>

Width  = 80;   // cm
Depth  = 40;   // cm
Height = 180;  // cm — open racking, up past head height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_shelves = true;
// The racking, in real cm: the uprights left at each side, the base under the bottom bay and
// the top shelf over the last one.
Upright   = 4;   // cm of side upright left at each end ...
Base      = 12;  // ... of base under the bottom bay (see base_h(): it holds the magnets) ...
Top_shelf = 3;   // ... and of top shelf over the highest one
Bays      = 0;   // bays up the unit (0 = one per Bay_target cm of the clear run)
Bay_target = 35; // cm — target clear height of one bay when deriving
Shelf_th  = 3;   // cm — a shelf, left standing at the face. Chunkier than a cabinet's: this
                 // is utility racking, and it is the only thing holding the bays apart
Bay_in    = 8;   // cm the bays are sunk into the front face

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the piece
// from pivoting; see Magnet_* in lib/common.scad. The 40 cm depth is only 10 mm at 1:40 —
// still room for the 4 mm disc with a wall either side, and a shallower shelf drops to the
// 2 mm one on its own.
Magnets = 2;

// The base, in real cm: what was asked for, but never so low that the magnet pocket in it
// reaches up into the bottom bay — rise_cm(magnet_pad_h()) is the pocket plus a little
// material over its ceiling, in the units the part is written in (as bedroom/ikea_pax.scad
// floors its own base).
function base_h() =
    min(Height / 3, max(Base, Magnets > 0 ? rise_cm(magnet_pad_h()) : 0));
// How many bays: as asked for, or one per Bay_target cm of the clear run between the base and
// the top shelf, so a taller unit gets more of them rather than deeper ones.
function bays() =
    Bays > 0 ? Bays
             : max(1, round((Height - base_h() - Top_shelf) / Bay_target));

storage_shelving();

module storage_shelving() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_shelves)
            front_bays(Width - 2 * Upright, Depth,
                       rise(base_h()), Print_h - rise(Top_shelf),
                       rows = bays(), depth_cm = Bay_in, rib_cm = Shelf_th);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
