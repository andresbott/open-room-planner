// livingroom / bookshelf — an open shelving unit token (BILLY-style): a real
// recessed front of stacked open compartments, not a symbol engraved on top.
//
// A bookshelf is open at the front, so that is where the shelves have to read —
// and a token seen from above cannot show them. This one carves them for real:
// the compartments are cut back into the FRONT (-Y) face the way washbasin.scad
// cuts its bowl, leaving side walls, a base, a shelf between each pair and a back
// panel. Printed on its BACK — front face up — every divider stands as a vertical
// wall, so the thin panels come out clean with nothing to bridge; upright, each
// shelf underside would be an overhang. That is what makes real shelves worth it
// here, where every other carcass just engraves a symbol.
//
// Width/Depth are the real-world footprint in cm — commonly 40/60/80 wide, 28
// deep (the BILLY carcass). Height is the real carcass height — 202 cm tall, or
// 106 for the half-height one — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so it is one of the tallest pieces of the set.
//
// A real 2 cm shelf is only 0.5 mm at 1:40, under two perimeters, so the panels
// print at a floor of Panel_min (the way lamp.scad floors its pole at Stem_min),
// rising to true scale only when the plan is drawn larger.

include <../lib/common.scad>

Width  = 80;   // cm
Depth  = 28;   // cm
Height = 202;  // cm — tall carcass (106 for the half-height one)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_shelves = true;
// Open compartments stacked up the front; 0 = derive one per Shelf_target cm of
// carcass, so the tall frame gets about six and the half-height one about three.
Compartments = 0;
Shelf_target = 33;   // cm — target clear height of one compartment when deriving
// Panel thicknesses in real cm — the side walls and shelves, and the back panel
// left at the +Y face — each floored at Panel_min printed mm so they still print
// at 1:40 (see the header).
Shelf_th  = 2;    // cm — side walls, shelves
Back_th   = 2;    // cm — back panel left at the +Y face
Panel_min = 0.8;  // printed mm — two perimeters at a 0.4 mm nozzle
// Magnet pockets in the bottom face (0 = none). A 28 cm-deep piece is 7 mm across
// at 1:40 — wide enough for a 4 mm disc; the base is kept thick enough to seat it.
Magnets = 1;

// ---- panel geometry (printed mm) --------------------------------------------
// A panel is a real thickness where the scale gives enough, else the print floor.
function panel_t() = max(cm(Shelf_th), Panel_min);
function back_t()  = max(cm(Back_th), Panel_min);
// The base carries the magnet pocket, so it keeps a wall of material over it.
function base_t()  = Magnets > 0 ? max(panel_t(), magnet_pocket_h() + Panel_min)
                                 : panel_t();
// Compartments: as asked for, or one per Shelf_target cm of the clear inner run
// (the carcass less the base and the top panel), measured back in real cm.
function n_comp() = Compartments > 0 ? Compartments
    : max(1, round(rise_cm(Print_h - base_t() - panel_t()) / Shelf_target));
// Clear height of one compartment: the run above the base, split n_comp() ways,
// less the shelf that divides each pair.
function comp_h() = (Print_h - base_t()) / n_comp() - panel_t();

bookshelf();

module bookshelf() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_shelves) shelves();
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// The open front: n_comp() compartments cut back into the -Y face, each the full
// clear width and the clear depth (a back panel is left at +Y), stacked from the
// base up with a shelf of panel_t() between each pair and the top panel left on.
module shelves() {
    t  = panel_t();
    n  = n_comp();
    ch = comp_h();
    if (ch < Panel_min)
        echo(str("WARNING: ", Width, "x", Height, " cm at 1:", Scale, " leaves ",
                 ch, " mm per compartment over ", n, " — too thin, shelves skipped"));
    else
        for (i = [0 : n - 1])
            compartment(base_t() + i * (ch + t) + ch / 2, ch);
}

// One open compartment: a full-width slot cut from the front (-Y) face back to the
// back panel, <ch> mm tall, centred at <cz> up from the bottom. Like washbasin.scad's
// front_cut(), the cut runs a hair past the front face so the mouth comes out clean.
module compartment(cz, ch) {
    w   = cm(Width) - 2 * panel_t();      // between the two side walls
    len = cm(Depth) - back_t() + 0.01;    // front face back to the back panel
    translate([0, -(back_t() + 0.01) / 2, cz])
        cube([w, len, ch], center = true);
}
