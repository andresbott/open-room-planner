// pool / pool — a swimming pool built from composable tiles, the way the walls build a room
// shell: not one printed pool, but a small kit of square tiles that BUTT flush on a fixed
// module and, laid out together, read as one pool — a coping (the paved rim) all the way round
// a continuous sheet of sunken water. Like the wall segments, every tile is the same size and
// square-ended so any two meet cleanly; unlike them, what a tile carries is not a length on its
// face but water sunk into its top and coping raised round the outside.
//
// Four Kinds make any rectangular pool, exactly as the walls' corner is just two segments
// butting:
//
//     corner   coping on TWO outside edges (-X and -Y), water on the inner quarter
//     edge     coping on ONE outside edge (-Y), water filling the rest — a side of the pool
//     water    no coping — water to every edge, an interior tile for a bigger pool
//     steps    an edge tile whose water STEPS down from the coping — the shallow-end entry
//
// The smallest pool is four corners (turned to face out — see below), which already give a full
// coping ring round four quarters of water. A longer pool drops `edge` tiles along the sides
// and `water` tiles in the middle between the corners; a `steps` tile replaces one edge where
// you get in:
//
//     [corner][ edge ][corner]        turn a corner/edge in the plan the way you turn a wall:
//     [ edge ][water ][ edge ]        the default corner faces its coping -X/-Y (a SW corner),
//     [corner][steps ][corner]        a quarter turn gives the other three corners and sides.
//
// On its open (butting) edges a tile's water runs right to the edge, so where two tiles meet
// there is no wall between them and the water reads as one continuous sheet; each tile is still
// a single solid piece, held together by its coping and by the floor that carries the water —
// an interior `water` tile is simply that floor, a low slab that sits below the coping round it.
//
// It prints the right way up with nothing to support: the water is a recess that opens UPWARD
// (its walls are vertical, like a real pool wall — no overhang), the coping is solid, and the
// steps rise as a plain staircase from the floor to the deck. Like the shower tray, a pool is
// nearly floor level, and its Height is set not by how tall a pool is but by what it takes to
// sink a visible pan of water ABOVE a magnet pocket — so it is a low tile, clamped to what fits
// and warning in the render log when the water had to be made shallower (give it more: POOL_H).
//
// Module is the tile's real-world side in cm (200 = a 2 m square; a 3x2 layout is a 6x4 m pool).
// Coping is the paved rim's real width. Height is the tile's real height in cm. Magnets sit in
// the solid floor under the water, like any near-square piece (see Magnet_* in lib/common.scad).

include <../lib/common.scad>

Kind   = "corner";  // corner | edge | water | steps
Module = 200;       // cm — the tile's side; every tile in a pool shares it, so they line up
Height = 35;        // cm — a low tile (a pool is near floor level; the height buries a magnet)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_water = true;
// The pool, real cm. Coping is the paved rim raised round the outside edges. Water_depth is how
// far the water sinks — clamped to what the height leaves over a magnet pocket (see water_dz(),
// which warns when it gave any back). On an open edge the water is run Bleed cm past the tile
// edge, so a butting neighbour's water joins it with no wall between — an internal detail, but
// exposed so a run of tiles that must overlap slightly can be tuned.
Coping      = 30;   // cm of raised paved rim on an outside edge
Water_depth = 20;   // cm the water sinks below the coping
Water_floor = 1.2;  // printed mm of material kept under the water, over a magnet pocket
Bleed       = 10;   // cm the water runs past an OPEN edge, so neighbours merge into one sheet

// The shallow-end steps (Kind = "steps"): a flight descending from the -Y coping into the pool.
Steps     = 3;    // treads from deck down to the pool floor ...
Steps_run = 55;   // ... and how far into the tile (cm) they reach before the full-depth water

// Coping joints: one groove down the middle of each paved rim, parallel to the pool edge, so a
// big flat band of coping reads as paving and not as a blank wall top. Ink, but the coping is
// the one big flat face here and a joint is genuinely a joint (cf. the wall's engraved length).
Show_joints = true;
Joint_w     = 2;    // cm — the groove width

// Magnet pockets in the bottom face (0 = none). A tile is a big near-square block with a full
// solid bottom (the water only cuts the top), so the pockets sit in the floor under the water
// like any piece; two keep a 2 m tile from pivoting between its neighbours.
Magnets = 2;

// ---- which edges carry coping, per Kind -------------------------------------
function cope_xn() = (Kind == "corner");                                   // -X outside edge
function cope_xp() = false;                                                // +X (always inner)
function cope_yn() = (Kind == "corner" || Kind == "edge" || Kind == "steps"); // -Y outside edge
function cope_yp() = false;                                                // +Y (always inner)

// The water rectangle, real cm from the tile centre: inset by the coping on an outside edge, and
// run Bleed past the tile edge on a butting one, so neighbours' water joins with no wall.
function wx0() = cope_xn() ? -Module / 2 + Coping : -Module / 2 - Bleed;
function wx1() = cope_xp() ?  Module / 2 - Coping :  Module / 2 + Bleed;
function wy0() = cope_yn() ? -Module / 2 + Coping : -Module / 2 - Bleed;
function wy1() = cope_yp() ?  Module / 2 - Coping :  Module / 2 + Bleed;

// How far the water sinks (printed mm), clamped to leave a magnet pocket plus its cover under it.
function water_under() = magnet_count(Module, Module, Magnets) > 0 ? magnet_pocket_h() : 0;
function water_dz()    = max(0, min(rise(Water_depth),
                                    Print_h - water_under() - Water_floor));
// The step run, clamped so it cannot reach past the water it is cut into.
function steps_run()   = min(Steps_run, wy1() - wy0());

pool();

module pool() {
    if (Show_water && water_dz() < rise(Water_depth) - 0.001)
        echo(str("WARNING: a ", Water_depth, " cm pool does not fit in a ", Height,
                 " cm tile over ", water_under(), " mm of magnet pocket — sunk ",
                 rise_cm(water_dz()), " cm instead (give it more: POOL_H)"));
    difference() {
        footprint(Module, Module, Print_h, r = 0);   // square ends, so tiles butt flush
        if (Show_water) water_cut();
        if (Show_joints) coping_joints();
        if (Magnets > 0) magnets(Module, Module, Magnets);
    }
}

// The water: one downward recess over the water rectangle for a flat pool floor, or — for the
// steps tile — a flight near the -Y coping (each tread cut a little deeper than the last) giving
// way to full-depth water beyond it.
module water_cut() {
    if (Kind == "steps" && steps_run() > 0) {
        n   = max(1, Steps);
        run = steps_run();
        for (k = [0 : n - 1])                          // the flight: shallow at the coping ...
            cut_box(wx0(), wx1(),
                    wy0() + run * k / n, wy0() + run * (k + 1) / n,
                    water_dz() * (k + 1) / n);
        if (wy1() - (wy0() + run) > 0.01)              // ... full depth beyond it
            cut_box(wx0(), wx1(), wy0() + run, wy1(), water_dz());
    } else {
        cut_box(wx0(), wx1(), wy0(), wy1(), water_dz());
    }
}

// One box of water removed from the top: over the real-cm rectangle [x0,x1] x [y0,y1], sunk
// <dz> printed mm. Walls come out vertical — a pool wall, and an upward recess the printer needs
// no support for.
module cut_box(x0, x1, y0, y1, dz) {
    if (x1 > x0 && y1 > y0 && dz > 0)
        translate([cm(x0), cm(y0), Print_h - dz])
            cube([cm(x1 - x0), cm(y1 - y0), dz + 0.1]);
}

// A joint groove down the centre of each paved rim, parallel to the pool edge it runs along.
module coping_joints() {
    if (cope_yn()) groove(0, -Module / 2 + Coping / 2, Module, Joint_w, Print_h);
    if (cope_xn()) groove(-Module / 2 + Coping / 2, 0, Joint_w, Module, Print_h);
}
