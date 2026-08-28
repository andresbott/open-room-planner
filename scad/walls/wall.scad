// walls / wall — a straight interior wall segment: a square-ended slab with its length
// engraved on one face, so a run can be picked out of the box and laid out by reading
// the numbers off the side. The face is where the number belongs on a piece this shape:
// even the thinnest partition is 12.5 mm tall and 6.25 mm long on its face, so every
// segment carries its size — on top, only the load-bearing walls were wide enough to.
// Thickness is not engraved; it reads off the ribbon itself, and off which segments
// butt flush against it.
//
// Thickness/Length are the real-world wall size in cm. Interior thicknesses:
//   11.5       non-load-bearing partition (half-brick masonry)
//   17.5, 24   load-bearing interior walls
// Height is the one exception in the catalogue: it is a PRINTED height in mm, not a
// real one. Every piece of furniture is modelled at its real height and shrunk by
// the plan scale (see printed_h() in lib/common.scad), but a full 250 cm wall at 1:40
// would be a 62.5 mm ribbon — you could not see into the room, and an opening would
// need a bridged lintel instead of the sill/threshold drop the segments use. So a wall
// is cut off part way up instead: 25 mm, which at 1:40 is a real 100 cm. That is enough
// to stand PROUD of the worktops and chests (22.5 mm) so a run reads as a room and not
// as a line on the board, while a wardrobe (59 mm) still rises well clear of it and you
// can see over the ribbon into the room. Every opening runs from its sill or threshold
// straight up to that cut, so nothing has to bridge.

include <../lib/common.scad>

Thickness = 24;   // cm — 11.5 partition, 17.5/24 load-bearing
Length    = 200;  // cm — segment length
Height    = 25;   // PRINTED mm — a real 100 cm at 1:40, not a scaled 250 cm wall

// Engrave the length on one face (the -Y one), centred and half way up. It is shrunk
// to fit the face; a segment too short for a legible number is left plain with a
// warning. At 1:40 they all carry it, the 25 cm stub included.
Show_label = true;

// Magnet pockets in the bottom face (0 = none). A wall is a thin ribbon — 2.875 mm
// across for the 11.5 cm partition, 6 for the 24 cm one — so at 1:40 the load-bearing
// walls drop to the small 2x1 disc, and the partition, too thin for even that, gets the
// material it needs instead of going without: a low round pad under each pocket, a
// touch proud of both faces near the floor (magnet_pads() in lib/common.scad — the
// render log says which pieces are padded). Along the length the count is clamped to
// what fits, so a short segment gets fewer.
Magnets = 2;

wall();

module wall() {
    difference() {
        union() {
            // square ends (r = 0) so segments butt flush and corners meet cleanly
            footprint(Length, Thickness, Height, r = 0);
            if (Magnets > 0) magnet_pads(Length, Thickness, Magnets);
        }
        if (Show_label) wall_label();
        if (Magnets > 0) magnets(Length, Thickness, Magnets, pad = true);
    }
}

// The length cut into the face. Sized to the face it has to fit — no taller than the
// ribbon, no longer than the segment — and dropped when that falls below the
// legibility floor, so a stub comes out clean instead of blobbed (cf. the symbols in
// lib/common.scad). It sits half way up, where a pad at the foot cannot reach it.
module wall_label() {
    txt  = str(Length);
    h    = Height     - 2 * Symbol_margin;         // room up the face
    w    = cm(Length) - 2 * Symbol_margin;         // ... along it
    size = label_size(w, h, txt);
    if (size >= Symbol_min)
        label_front(txt, Thickness, z = Height / 2, size = size);
    else
        echo(str("WARNING: ", Thickness, "x", Length,
                 " cm wall at 1:", Scale, " is too short to engrave its length"));
}
