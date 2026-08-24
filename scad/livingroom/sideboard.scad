// livingroom / sideboard — a low sideboard / display cabinet token, with
// mixed fronts engraved on top: a shallow row of drawers at the back, doors
// at the front.
//
// Width/Depth are the real-world footprint in cm: a 160 cm sideboard, 45 cm
// deep. Height is the real height of the carcass — about hip height, like a chest
// of drawers — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad).

include <../lib/common.scad>

Width  = 160;  // cm
Depth  = 45;   // cm
Height = 80;   // cm

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// Mixed fronts: a shallow band of stacked drawers along the back (+Y) half
// of the top face, and door seams along the front (-Y) half. Drawers stack
// vertically, doors sit side by side, so the two bands read apart even
// engraved this small.
Show_fronts = true;
Front_rows  = 2;   // drawer fronts stacked in the back band
Doors       = 3;   // door leaves in the front band, marked by (Doors - 1) seams
// Magnet pockets in the bottom face, in a row along the width (0 = none).
// Two keep the piece from pivoting; 45 cm deep is 11.25 mm at 1:40, plenty for
// a 4 mm disc; see Magnet_* in lib/common.scad.
Magnets = 2;

sideboard();

module sideboard() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_fronts) fronts();
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// Symbol_margin/Symbol_stroke are fixed printed-mm constants; groove() takes
// real-world cm and converts it with cm(). This undoes that conversion, so a
// printed-mm distance can be handed to groove() unchanged.
function to_cm(v) = v * Scale / 10;

// The mixed-fronts detail: a drawers band across the back half of the top
// face, door seams grooved across the front half, split by a hairline gap so
// the two bands read apart.
module fronts() {
    patch_w  = cm(Width) - 2 * Symbol_margin;
    patch_h  = cm(Depth) - 2 * Symbol_margin;
    gap      = Symbol_margin;             // keeps the two bands apart
    drawer_h = (patch_h - gap) * 0.4;     // shallower, like a real drawer row
    door_h   = (patch_h - gap) * 0.6;     // taller, like the cupboard below it
    drawer_y = patch_h / 2 - drawer_h / 2;   // flush with the back of the patch
    door_y   = -patch_h / 2 + door_h / 2;    // flush with the front of the patch
    seam_w   = Symbol_stroke + 0.1;       // a hair over one nozzle
    ratio    = patch_w / drawer_h;        // stretches the drawers band edge to edge

    union() {
        // the drawers band: as wide as the piece allows, Front_rows fronts
        // stacked inside it
        translate([0, drawer_y, 0])
            drawers(drawers_size(patch_w, drawer_h, ratio = ratio), Print_h,
                    ratio = ratio, rows = Front_rows);

        // the doors band: (Doors - 1) vertical seams, evenly spaced — an open
        // cabinet reads fine from the seams alone, no outline needed
        for (i = [1 : Doors - 1])
            groove(to_cm(-patch_w / 2 + patch_w * i / Doors), to_cm(door_y),
                   to_cm(seam_w), to_cm(door_h), Print_h);
    }
}
