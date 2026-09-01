// kidsroom / cube_storage — an open cube-storage shelving unit token (KALLAX-style):
// a real egg-crate of open cubbies cut into the FRONT (-Y) face, not a grid engraved on
// the top. It used to be a footprint() box with the Cols x Rows grid scored onto its top
// face — the labelled brick the set forbids, and drawn on the one face a photograph of
// the plan barely sees. A KALLAX is an open cube shelf; the one thing it has to be is
// open, and open is a thing you can only show from the front.
//
// So the cubbies are carved for real, the way livingroom/bookshelf.scad and
// office/ikea_ivar.scad carve their shelves: front_bays() cuts a Cols x Rows grid of deep
// recesses back through almost the whole depth, leaving the outer carcass, a mullion
// between every pair of columns and a shelf between every pair of rows standing as one
// uniform egg-crate, with a thin back panel at +Y. Deep, even, chunky-framed square-ish
// cells with no fronts, no doors and no handles are what a KALLAX is, and what tell it
// apart from its neighbours: bookshelf.scad is one tall narrow column of thin shelves,
// laundry/storage_shelving.scad a stack of shallow niches over a fat base — this is a
// deep square grid. There is nothing on the top: the unit reads by the cubbies you can
// count from the front, not by a number scored where you cannot see it.
//
// PRINTS ON ITS BACK — back face (+Y) down on the bed, open front facing up. Cut this
// deep and left standing upright, every shelf would be a ceiling bridging front-to-back
// over the cubby beneath it; laid on its back the whole egg-crate grows straight up off
// the back panel as a set of clean vertical walls — nothing overhangs, nothing bridges.
// The back panel is what the piece lies on, so — unlike ikea_ivar's optional open frame —
// it is always kept. The magnet pockets are cut into the base at z = 0 as on every part
// (the model itself stays upright); laid on its back to print they open sideways, as the
// other on-its-back parts' pockets do.
//
// Cols x Rows are the cubbies across the width and up the height — keep Width and Height
// in step with them, because a real KALLAX cube is about 39 cm square: 77x77 is the 2x2,
// 77x147 the 2x4, 147x147 the 4x4. Width/Depth are the real footprint in cm (a cube shelf
// is one cube — 39 cm — deep whatever the grid), Height the real carcass height, all
// shrunk by the plan scale (see printed_h() in lib/common.scad).
//
// A real 4 cm KALLAX divider is only 1 mm at 1:40 and a 2 cm back panel half that, so the
// frame and the back print at a floor of Panel_min (two perimeters), rising to true scale
// only when the plan is drawn larger — as bookshelf.scad floors its own panels. The base
// rail is left deeper still, enough to bury a magnet under a wall of material, which is
// what leaves the cells a shade shorter than they are wide.

include <../lib/common.scad>

Cols   = 2;   // cubbies across the width — keep Width in step (77 for 2, 147 for 4)
Rows   = 2;   // cubbies up the height  — keep Height in step (77 for 2, 147 for 4)
Width  = 77;  // cm — a KALLAX cube is ~39 wide, so 77 = 2 columns, 147 = 4
Depth  = 39;  // cm — one cube deep, whatever the grid
Height = 77;  // cm — 77 = 2 rows, 147 = 4

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_cubbies = true;
// The KALLAX frame in real cm — the outer carcass, the mullion between two columns and
// the shelf between two rows, all one uniform thickness (a chunky ~4 cm board is what a
// KALLAX is, and what tells it from a thin-shelved bookshelf). Floored at Panel_min
// printed mm so it still prints at 1:40 (see the header).
Frame   = 3.8;
// The thin back panel left at the +Y face, in real cm — a KALLAX cube has a back, and
// laid on its back to print it is the face the piece lies on, so it is always kept
// (floored at Panel_min like the frame).
Back_th = 2;
Panel_min = 0.8;  // printed mm — two perimeters at a 0.4 mm nozzle
// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep the
// unit from pivoting on the board; see Magnet_* in lib/common.scad. A 39 cm-deep base is
// 9.75 mm across at 1:40 — wide enough for a 4 mm disc, and the base rail is kept thick
// enough to seat one (see base_t()).
Magnets = 2;

// ---- panel geometry (printed mm) --------------------------------------------
// A panel is its real thickness where the scale gives enough, else the print floor.
function panel_t() = max(cm(Frame), Panel_min);      // carcass, mullions, ribs, top
function back_t()  = max(cm(Back_th), Panel_min);    // the back panel at +Y
// The base rail carries the magnet pocket, so it keeps a wall of material over it.
function base_t()  = Magnets > 0 ? max(panel_t(), magnet_pocket_h() + Panel_min)
                                 : panel_t();
// How deep the cubbies are cut from the front, handed to front_bays() in real cm: the
// whole depth bar the back panel. The cut is worked out in printed mm and passed back
// through plan_cm(), so front_bays() leaves exactly back_t() of back panel — clear of the
// back face, never coincident with it.
function cut_cm()  = plan_cm(cm(Depth) - back_t());

cube_storage();

module cube_storage() {
    difference() {
        footprint(Width, Depth, Print_h);
        // Cols x Rows open cubbies cut into the front (-Y) face: the width inset by a
        // frame each side, the band between the base rail and the top, deep to the back
        // panel, with a frame-thick mullion and rib left between the cells. See the
        // header for why it is cut this deep and printed on its back.
        if (Show_cubbies)
            front_bays(Width - 2 * Frame, Depth,
                       base_t(), Print_h - panel_t(),
                       rows = Rows, cols = Cols,
                       depth_cm = cut_cm(), rib_cm = Frame, mullion_cm = Frame);
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
}
