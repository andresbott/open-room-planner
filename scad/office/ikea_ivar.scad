// office / ikea_ivar — an IKEA IVAR pine shelving unit token: a real open frame of
// bays and shelves, not a symbol engraved on top.
//
// A shelving unit is open at the front, so that is where the shelves have to read — and
// a token seen from above cannot show them. So this one carves them for real, the way
// bookshelf.scad does: the openings are cut back into the FRONT (-Y) face, leaving the
// two outer posts, a post between each pair of bays, a base, a shelf between each pair,
// the top, and a back panel at +Y. Printed on its BACK — front face up — every post and
// every shelf stands as a vertical wall, so the thin panels come out clean with nothing
// to bridge; upright, each shelf underside would be an overhang. That is what makes real
// shelves worth it here, where every other carcass just engraves a symbol.
//
// The real IVAR has NO back — it is a pair of ladder side units with shelves laid
// between them, and you can see the wall through it. This one keeps a back panel
// anyway, for the print: laid on its back the panel is a continuous first layer instead
// of a grid of single-perimeter walls with nothing tying them down, and it braces every
// post and shelf, which are all at the Panel_min floor at 1:40. Set Back_th = 0 for the
// true open frame — it still renders, and at a larger scale the panels are thick enough
// to hold themselves. What then tells this apart from bookshelf.scad is what always did:
// its bays side by side, and the IVAR sizes.
//
// Width/Depth/Height are the real-world unit size in cm, the sizes IKEA sells:
//
//   width   48 (one 42 cm shelf)   89 (one 83)   174 (two 83)   259 (three 83)
//   depth   30 or 50               (the two side-unit depths)
//   height  124, 179 or 226        (ditto)
//
// all three shrunk by the plan scale (see printed_h() in lib/common.scad), so a 226 cm
// unit stands with the tallest pieces of the set. The width is engraved on the top face
// (see Show_width), so a run can be picked out of the box by reading the number.
//
// Bays and shelves are DERIVED from that size rather than counted out by hand, and the
// defaults below are the numbers that make the real unit come out right: at Bay_target
// = 83 and Side_th = 3 the four widths give 1 / 1 / 2 / 3 bays with a ~42 / ~83 cm shelf
// in each, and at Shelf_target = 35 the three heights give 3 / 5 / 6 shelves — about
// what the unit ships with, and about how far apart you would hang them.
//
// A real 2 cm shelf is only 0.5 mm at 1:40, under two perimeters, so the panels print
// at a floor of Panel_min, the way bookshelf.scad floors its own; they rise to true
// scale only when the plan is drawn larger.

include <../lib/common.scad>

Width  = 89;   // cm — 48 / 89 / 174 / 259 (see the header)
Depth  = 30;   // cm — 30 or 50, the two side-unit depths
Height = 179;  // cm — 124 / 179 / 226

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_shelves = true;
// The width engraved on the top face, so a unit can be picked out of the box by reading
// the number rather than by measuring — as the wall segments carry their length. Only
// the width: the depth and the height read off the piece itself, and the width is the
// one thing two units of the same shape differ by. It goes on TOP and not on the back
// face (the bigger surface, now that there is a back panel) because the top is the one
// you can read with the piece standing on the plan.
Show_width = true;
// Bays side by side across the width; 0 = derive one per Bay_target cm of shelf plus
// the post beside it, so the four IVAR widths give 1 / 1 / 2 / 3 (see the header).
Bays       = 0;
Bay_target = 83;   // cm — the wide IVAR shelf, the bay width to aim for
// Shelves stacked up each bay; 0 = derive one per Shelf_target cm of the frame, so the
// three IVAR heights give 3 / 5 / 6.
Shelves      = 0;
Shelf_target = 35;  // cm — target clear height of one shelf opening when deriving
// Panel thicknesses in real cm — the shelves and the top, and the side-unit posts —
// each floored at Panel_min printed mm so they still print at 1:40 (see the header).
Shelf_th  = 2;    // cm — shelves, base, top
Side_th   = 3;    // cm — the posts: an outer one either side, one between two bays
// The back panel left at the +Y face, in real cm — what makes the piece printable (see
// the header). 0 leaves it off and cuts the bays straight through, for the open frame
// the real unit is.
Back_th   = 2;    // cm — 0 = open at the back, as the real unit is
Panel_min = 0.8;  // printed mm — two perimeters at a 0.4 mm nozzle
// Magnet pockets in the bottom face, in a row along the width (0 = none). A 30 cm-deep
// unit is 7.5 mm across at 1:40 — wide enough for a 4 mm disc; the base is kept thick
// enough to seat it. One is enough on the 48 cm unit; the wider ones are long enough
// to pivot on a single pocket, so the Makefile asks them for two.
Magnets = 2;

// ---- panel geometry (printed mm) --------------------------------------------
// A panel is a real thickness where the scale gives enough, else the print floor.
function panel_t() = max(cm(Shelf_th), Panel_min);
function side_t()  = max(cm(Side_th),  Panel_min);
// ... and the back panel only if one was asked for at all.
function back_t()  = Back_th > 0 ? max(cm(Back_th), Panel_min) : 0;
// The base carries the magnet pocket, so it keeps a wall of material over it.
function base_t()  = Magnets > 0 ? max(panel_t(), magnet_pocket_h() + Panel_min)
                                 : panel_t();
// ... and the top carries the engraved width, so it does the same for the letters: a
// 0.4 mm cut into a 0.8 mm panel would leave two layers under the number.
function top_t()   = Show_width ? max(panel_t(), Label_depth + Panel_min) : panel_t();

// Bays: as asked for, or one per Bay_target cm of shelf plus the post beside it.
function n_bays() = Bays > 0 ? Bays
    : max(1, round(Width / (Bay_target + Side_th)));
// Clear width of one bay: the width less a post per bay plus the outer one, split
// n_bays() ways. Derived rather than taken from Bay_target, so the posts and the bays
// always add up to Width exactly whatever width is asked for (IKEA's own numbers carry
// half a centimetre of slop per bay on the wide units).
function bay_w() = (cm(Width) - (n_bays() + 1) * side_t()) / n_bays();

// Shelves: as asked for, or one per Shelf_target cm of the clear inner run (the frame
// less the base and the top), measured back in real cm.
function n_shelves() = Shelves > 0 ? Shelves
    : max(1, round(rise_cm(Print_h - base_t() - top_t()) / Shelf_target));
// Clear height of one shelf opening: the run between the base and the top, less the
// shelf that divides each pair, split n_shelves() ways.
function shelf_h() = (Print_h - base_t() - top_t()
                      - (n_shelves() - 1) * panel_t()) / n_shelves();

ikea_ivar();

module ikea_ivar() {
    difference() {
        // no corner rounding: at 1:40 an outer post is already down at the Panel_min
        // floor, and a 0.6 mm radius at the four corners of the footprint would pinch
        // its front edge to a fraction of that — square-cut suits pine anyway
        footprint(Width, Depth, Print_h, r = 0);
        if (Show_shelves) frame();
        if (Show_width) width_label();
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}

// The width cut into the top face, centred on it and sized to the patch of top the piece
// has (label_size, as the wall segments do) — so a 48 gets the same number as a 259,
// just smaller. Under Symbol_min it would come out a blob, so it is left off instead and
// said in the render log.
module width_label() {
    size = label_size(cm(Width) - 2 * Symbol_margin, cm(Depth) - 2 * Symbol_margin,
                      str(Width));
    if (size < Symbol_min)
        echo(str("NOTE: ", Width, "x", Depth, " cm at 1:", Scale,
                 " leaves no room for the width on top — engraving skipped"));
    else
        label(str(Width), Print_h, size = size);
}

// The open front: n_bays() x n_shelves() openings cut into the -Y face, each the clear
// width of its bay and the clear depth (a back panel is left at +Y), stacked from the
// base up with a shelf of panel_t() between each pair and the top panel left on.
module frame() {
    nb = n_bays();
    ns = n_shelves();
    bw = bay_w();
    sh = shelf_h();
    if (bw < Panel_min)
        echo(str("WARNING: ", Width, " cm at 1:", Scale, " leaves ", bw,
                 " mm per bay over ", nb, " — too thin, frame skipped"));
    else if (sh < Panel_min)
        echo(str("WARNING: ", Width, "x", Height, " cm at 1:", Scale, " leaves ", sh,
                 " mm per shelf over ", ns, " — too thin, frame skipped"));
    else
        for (i = [0 : nb - 1])
            for (j = [0 : ns - 1])
                opening(-cm(Width) / 2 + side_t() + i * (bw + side_t()) + bw / 2, bw,
                        base_t() + j * (sh + panel_t()) + sh / 2, sh);
}

// One opening: a slot <bw> mm wide centred at <bx> across the piece and <sh> mm tall
// centred at <bz> up from the bottom, cut from the front (-Y) face back to the back
// panel — or straight out of the back face when there is none. Like bookshelf.scad's
// compartment(), the cut runs a hair past each open face so the mouth comes out clean.
module opening(bx, bw, bz, sh) {
    y0 = -cm(Depth) / 2 - 0.01;                                    // past the front
    y1 =  cm(Depth) / 2 - back_t() + (back_t() > 0 ? 0 : 0.01);     // to the back panel,
    translate([bx, (y0 + y1) / 2, bz])                              // or past the back
        cube([bw, y1 - y0, sh], center = true);
}
