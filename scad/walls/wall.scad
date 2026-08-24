// walls / wall — a straight interior wall segment: a square-ended slab standing a
// touch proud of the furniture, with its thickness engraved on top so a
// load-bearing wall reads apart from a partition (they differ only by how thick
// they are — see Thickness).
//
// Thickness/Length are the real-world wall size in cm. Interior thicknesses:
//   11.5       non-load-bearing partition (half-brick masonry)
//   17.5, 24   load-bearing interior walls
// Height is the one exception in the catalogue: it is a PRINTED height in mm, not a
// real one. Every piece of furniture is modelled at its real height and shrunk by
// the plan scale (see printed_h() in lib/common.scad), but a 250 cm wall at 1:40
// would be a 62.5 mm ribbon — you could not see into the room, and an opening would
// need a bridged lintel instead of the sill/threshold drop the segments use. So a
// wall is deliberately a low backdrop: it stands a little PROUD of the worktops and
// chests, and well short of the wardrobes, which still read against it.

include <../lib/common.scad>

Thickness = 24;   // cm — 11.5 partition, 17.5/24 load-bearing
Length    = 200;  // cm — segment length
Height    = 7;    // PRINTED mm — a low backdrop, not a scaled 250 cm wall

// Engrave the thickness on top (the number that tells a partition from a bearing
// wall). It is shrunk to fit the ribbon; a wall too thin or short for a legible
// number is left off with a warning. At 1:40 the load-bearing walls carry it
// (17.5 cm is 4.4 mm thick, 24 cm is 6) but the 11.5 cm partition — a 2.875 mm
// ribbon — does not: it comes out plain, and says so in the render log.
Show_label = true;

// Magnet pockets in the bottom face (0 = none). A wall is a thin ribbon — 2.875 mm
// across for the 11.5 cm partition, 6 for the 24 cm one — so at 1:40 the
// load-bearing walls drop to the small 2x1 disc and the partition is too thin for
// even that: it prints solid (magnets() picks; it says which in the render log).
// Along the length the count is clamped to what fits, so a short segment gets fewer.
Magnets = 2;

wall();

module wall() {
    difference() {
        // square ends (r = 0) so segments butt flush and corners meet cleanly
        footprint(Length, Thickness, Height, r = 0);
        if (Show_label) wall_label(Height);
        if (Magnets > 0) magnets(Length, Thickness, Magnets);
    }
}

// The thickness cut into the top face. Sized to the ribbon it has to fit — no
// taller than the wall is thick, no longer than the wall is long — and dropped
// when that falls below the legibility floor, so a short or thin wall comes out
// clean instead of blobbed (cf. the symbols in lib/common.scad).
module wall_label(top_z) {
    txt  = str(Thickness);
    h    = cm(Thickness) - 2 * Symbol_margin;      // room across the thickness
    w    = cm(Length)    - 2 * Symbol_margin;      // ... along the length
    size = min(Label_size, h, w / (0.7 * len(txt)));
    if (size >= Symbol_min)
        label(txt, top_z, size = size);
    else
        echo(str("WARNING: ", Thickness, "x", Length,
                 " cm wall at 1:", Scale, " is too thin to engrave its size"));
}
