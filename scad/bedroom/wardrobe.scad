// bedroom / wardrobe — a standalone sliding-door wardrobe token, with vertical
// door-seam grooves engraved on top and nothing else.
//
// Width/Depth are the real-world footprint in cm: freestanding sliding
// wardrobes run anywhere from a narrow 100 cm up to a 200 cm wide run, 60 cm
// deep. Height is the real carcass height — a full-height sliding wardrobe, the
// same 236 cm as a tall PAX frame — shrunk by the plan scale like the footprint
// (see printed_h() in lib/common.scad), so it is one of the tallest pieces of the
// set; the door seams (not a hanger) are what tell it apart from a PAX.

include <../lib/common.scad>

Width  = 150;  // cm (100..200)
Depth  = 60;   // cm
Height = 236;  // cm — full-height carcass

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_doors = true;
// Door seams: vertical grooves cut into the top face, splitting the front into
// sliding doors — two seams (3 doors) up to Seam3_from cm wide, a third seam
// (4 doors) beyond that, so no single door panel reads unrealistically wide.
Seam3_from    = 170;  // cm
Door_groove_w = 2;    // cm — real-world seam width (0.5 mm printed at 1:40)
Door_margin   = 6;    // cm kept clear at the front/back edge of every groove
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting; see Magnet_* in lib/common.scad.
Magnets = 2;

wardrobe();

module wardrobe() {
    seams = Width >= Seam3_from ? 3 : 2;
    doors = seams + 1;
    difference() {
        footprint(Width, Depth, Print_h);
        // seams split the front into sliding doors — unlike PAX's hanger,
        // nothing here reads as "a single hinged frame"
        if (Show_doors)
            for (i = [1 : seams])
                groove(-Width / 2 + i * Width / doors, 0,
                       Door_groove_w, Depth - 2 * Door_margin, Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
