// pool / pool — a swimming pool built from composable tiles, the way the walls build a room
// shell: not one printed pool, but a small kit of square tiles that BUTT flush on a fixed
// module and, laid out together, read as one pool — a coping (the paved rim) all the way round
// a continuous sheet of sunken water. Like the wall segments, every tile is the same size and
// square-ended so any two meet cleanly; unlike them, what a tile carries is not a length on its
// face but water sunk into its top and coping raised round the outside.
//
// Six Kinds make any pool, exactly as the walls' corner is just two segments butting:
//
//     corner   coping on TWO outside edges (-X and -Y), water on the inner quarter
//     edge     coping on ONE outside edge (-Y), water filling the rest — a side of the pool
//     water    no coping — water to every edge, an interior tile for a bigger pool
//     steps    an edge tile whose water STEPS down from the coping — the shallow-end entry
//     round    a corner whose OUTSIDE corner and water edge are rounded (a curved pool end);
//              the two straight edges still butt, so only the free corner curves
//     ladder   an edge tile with a narrow, multi-tread flight of entry steps — a pool ladder,
//              the deep-end way in, its step edges reading as rungs where a Roman step won't fit
//
// The smallest pool is four corners (turned to face out — see below), which already give a full
// coping ring round four quarters of water. A longer pool drops `edge` tiles along the sides
// and `water` tiles in the middle between the corners; a `steps` or `ladder` tile replaces one
// edge where you get in, and a `round` corner swaps a square corner for a curved one:
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
// (its walls are vertical, like a real pool wall — no overhang), the coping is solid, the steps
// and the ladder flight rise as a plain staircase from the floor to the deck. The pool is left as
// an EMPTY BASIN — a bare sunken floor, with no water surface modelled in it. Like the shower tray, a
// pool is nearly floor level, and its Height is set not by how tall a pool is but by what it
// takes to sink a visible pan of water ABOVE a magnet pocket — so it is a low tile, clamped to
// what fits and warning in the render log when the water had to be made shallower (POOL_H).
//
// Module is the tile's real-world side in cm (200 = a 2 m square; a 3x2 layout is a 6x4 m pool).
// Coping is the paved rim's real width. Height is the tile's real height in cm. Magnets sit in
// the solid floor under the water, like any near-square piece (see Magnet_* in lib/common.scad).

include <../lib/common.scad>

Kind   = "corner";  // corner | edge | water | steps | round | ladder
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

// The rounded corner (Kind = "round"): the outside corner and the water edge sweep a quarter
// circle instead of turning a right angle. Corner_r is the OUTER radius in real cm (0 = auto, a
// full quarter round of Module/2); the water edge follows it one Coping in, so the paved rim
// keeps its width round the curve. Only the free -X/-Y corner curves — the +X/+Y edges stay
// square, so a round tile still butts its neighbours.
Corner_r = 0;

// The pool ladder (Kind = "ladder"): a LADDER FRAME of round tube standing at the -Y pool edge —
// two rails joined at the top, with rungs across, that rise from the pool floor and then curve OVER
// THE POOL BORDER toward the deck, the way a real pool ladder's handrails arch over. It is the
// recognisable ladder silhouette (one connected frame, not two loose posts), built from THICK round
// bars so it prints sturdy rather than as thin wire, and kept low. The rungs and the top span the
// short gap between the rails as short bridges — a ladder is open rungs, and the span is short
// enough to print clean; the hair-thin curved tubes of a real ladder are the only thing that won't.
Ladder_w   = 40;  // cm — the frame's outer width, rail to rail (narrow, so it reads as a ladder)
Bar_w      = 11;  // cm — the rail tube diameter (thick, so it prints sturdy, not a thin wire)
Rung_w     = 8;   // cm — the rung tube diameter
Rungs      = 4;   // treads up the straight part, where they show above the deck
Rail_up    = 28;  // cm the rails rise straight above the deck before curving over
Arch_rise  = 12;  // cm the curved top adds above that ...
Arch_over  = 10;  // ... leaning this far toward the deck, out over the pool border

// Coping joints: one groove down the middle of each paved rim, parallel to the pool edge, so a
// big flat band of coping reads as paving and not as a blank wall top. Ink, but the coping is
// the one big flat face here and a joint is genuinely a joint (cf. the wall's engraved length).
Show_joints = true;
Joint_w     = 2;    // cm — the groove width

// Magnet pockets in the bottom face (0 = none). A tile is a big near-square block with a full
// solid bottom (the water only cuts the top), so the pockets sit in the floor under the water
// like any piece; two keep a 2 m tile from pivoting between its neighbours. Centre_magnet adds
// one more pocket in the very middle — a 2 m tile is a wide, near-square sheet, and a third
// pocket at its centre stops it lifting or drumming between the two in the row.
Magnets       = 2;
Centre_magnet = true;

// ---- which edges carry coping, per Kind -------------------------------------
function is_corner() = (Kind == "corner" || Kind == "round");            // two outside edges
function cope_xn() = is_corner();                                        // -X outside edge
function cope_xp() = false;                                              // +X (always inner)
function cope_yn() = (is_corner() || Kind == "edge" || Kind == "steps"
                                  || Kind == "ladder");                  // -Y outside edge
function cope_yp() = false;                                              // +Y (always inner)

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
function floor_z()     = Print_h - water_dz();   // the flat pool floor, printed mm

// The rounded corner's outer radius (real cm), clamped so it leaves a full-width coping (a water
// edge inside the tile) and never overruns the tile — and the arc centre, on the diagonal.
function corner_r()  = min(Module / 2, max(Coping + 5, Corner_r > 0 ? Corner_r : Module / 2));
function corner_c()  = -Module / 2 + corner_r();   // arc centre x (= y, by symmetry)

pool();

module pool() {
    if (Show_water && water_dz() < rise(Water_depth) - 0.001)
        echo(str("WARNING: a ", Water_depth, " cm pool does not fit in a ", Height,
                 " cm tile over ", water_under(), " mm of magnet pocket — sunk ",
                 rise_cm(water_dz()), " cm instead (give it more: POOL_H)"));
    union() {
        difference() {
            linear_extrude(height = Print_h) tile_2d();  // square ends, so tiles butt flush
            if (Show_water) water_cut();
            if (Show_joints) coping_joints();
            pool_magnets();
        }
        // added on top of the solid: the ladder frame
        if (Kind == "ladder") ladder_frame();
    }
}

// ---- the tile outline -------------------------------------------------------
// A plain square, except the `round` tile, whose free (-X,-Y) corner is swept to a quarter
// circle of corner_r(). The rounding is a corner nub removed from the square: the little
// corner box minus the arc disc is exactly the sharp corner outside the curve.
module tile_2d() {
    if (Kind == "round")
        difference() {
            box_2d(-Module / 2, Module / 2, -Module / 2, Module / 2);
            corner_nub_2d(corner_r());
        }
    else
        box_2d(-Module / 2, Module / 2, -Module / 2, Module / 2);
}

// The sharp corner outside an arc of radius <r> about corner_c(): the r x r box at the tile's
// (-X,-Y) corner with the arc disc taken out. Removed from a square it rounds that one corner;
// removed from the water rectangle it rounds the water's inner edge to match.
module corner_nub_2d(r) {
    c = corner_c();
    difference() {
        box_2d(-Module / 2, c, -Module / 2, c);
        translate([cm(c), cm(c)]) circle(r = cm(r));
    }
}

// A rectangle given by its real-cm edges, as a 2D region centred where it belongs.
module box_2d(x0, x1, y0, y1) {
    if (x1 > x0 && y1 > y0)
        translate([cm((x0 + x1) / 2), cm((y0 + y1) / 2)])
            square([cm(x1 - x0), cm(y1 - y0)], center = true);
}

// ---- the water --------------------------------------------------------------
// The water: one downward recess for a flat pool floor, the `round` tile's rounded region, or —
// for `steps` — a flight near the -Y coping (each tread cut a little deeper than the last)
// giving way to full-depth water beyond it. The `ladder` tile cuts full-depth water like an
// edge and gets its ladder frame added back on top (ladder_frame).
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
    } else if (Kind == "round") {
        translate([0, 0, floor_z()])
            linear_extrude(height = water_dz() + 0.1) round_water_2d();
    } else {
        cut_box(wx0(), wx1(), wy0(), wy1(), water_dz());
    }
}

// The rounded water region: the water rectangle with its inner corner (nearest the tile's free
// corner) cut back to the arc one Coping inside the outer curve, so the paved rim keeps its
// width all the way round the bend.
module round_water_2d() {
    difference() {
        box_2d(wx0(), wx1(), wy0(), wy1());
        corner_nub_2d(corner_r() - Coping);
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

// ---- the ladder -------------------------------------------------------------
// A flat ladder frame standing at the -Y pool edge: two rails from the pool floor up past the deck,
// joined at the top by a bar (an inverted U, so it reads as one frame and not two posts), with
// Rungs treads down the submerged part. Its feet stand on the pool floor, welding it to the tile;
// it stands a little clear of the wall so the whole silhouette shows. Built from rounded flat bars
// (a hull of two discs), thin in Y — a cut-out ladder. The rungs and top bar are short bridges (see
// the header): a ladder is open rungs, and at this narrow width the span prints clean.
module ladder_frame() {
    yc     = wy0() + Bar_w / 2 + 2;                 // frame plane, just inside the pool edge (cm)
    z_bot  = floor_z();                             // feet, on the pool floor (printed mm)
    z_knee = Print_h + rise(Rail_up);               // top of the straight part
    z_top  = z_knee + rise(Arch_rise);              // the arched handrail top ...
    y_top  = yc - Arch_over;                        // ... leaned over the pool border, toward -Y
    rx     = Ladder_w / 2 - Bar_w / 2;             // each rail's centre, in from the edge
    for (s = [-1, 1]) {
        tube([s * rx, yc, z_bot],  [s * rx, yc, z_knee], Bar_w);       // the straight rail
        tube([s * rx, yc, z_knee], [s * rx, y_top, z_top], Bar_w);     // the curve over the border
    }
    tube([-rx, y_top, z_top], [rx, y_top, z_top], Bar_w);             // the top handrail bar
    // the rungs, up the straight part so they show above the deck
    n  = max(1, Rungs);
    zt = z_knee - rise(4);
    zb = z_bot + rise(5);
    for (k = [0 : n - 1]) {
        z = n > 1 ? zb + (zt - zb) * k / (n - 1) : (zt + zb) / 2;
        tube([-rx, yc, z], [rx, yc, z], Rung_w);
    }
}

// A round tube of diameter <w> cm between two points, each [x_cm, y_cm, z_printed_mm] — a hull of
// two spheres, so it runs in any direction (the rails curve out over the border) and stays a clean
// round bar that prints sturdy.
module tube(a, b, w) {
    hull() for (p = [a, b])
        translate([cm(p[0]), cm(p[1]), p[2]]) sphere(d = cm(w), $fn = 18);
}

// ---- coping and magnets -----------------------------------------------------
// A joint groove down the centre of each paved rim, parallel to the pool edge it runs along. On
// the rounded corner the -X and -Y joints stop at the bend and a quarter-circle joint carries
// the line round it, so the paving reads as one band round the curve.
module coping_joints() {
    if (Kind == "round") {
        c = corner_c();
        mid = corner_r() - Coping / 2;                          // the band's centre radius
        if (cope_yn())
            groove((c + Module / 2) / 2, -Module / 2 + Coping / 2,
                   Module / 2 - c, Joint_w, Print_h);           // the -Y straight, beyond the bend
        if (cope_xn())
            groove(-Module / 2 + Coping / 2, (c + Module / 2) / 2,
                   Joint_w, Module / 2 - c, Print_h);           // the -X straight, beyond the bend
        translate([0, 0, Print_h - Label_depth])
            linear_extrude(height = Label_depth + 0.01)
                translate([cm(c), cm(c)]) stroke_arc(cm(mid), 180, 270, cm(Joint_w));
    } else {
        if (cope_yn()) groove(0, -Module / 2 + Coping / 2, Module, Joint_w, Print_h);
        if (cope_xn()) groove(-Module / 2 + Coping / 2, 0, Joint_w, Module, Print_h);
    }
}

// The pockets in the bottom face: the usual row, and — where Centre_magnet asks and the row has
// not already put one dead centre (an odd count does) — one more in the very middle of the tile.
module pool_magnets() {
    if (Magnets > 0)
        magnets(Module, Module, Magnets);
    if (Centre_magnet && water_under() > 0 && !row_has_centre()) {
        dia = magnet_d_for(Module, Module);
        magnet_pocket(0, 0, dia, magnet_h_for(dia));
    }
}

// True when the magnet row already lands a pocket on the tile centre, so Centre_magnet would
// only cut the same hole twice.
function row_has_centre() =
    len([for (p = magnet_row(Module, Module, Magnets))
             if (abs(p[0]) < 0.01 && abs(p[1]) < 0.01) 1]) > 0;
