// kidsroom / changing_table — a baby changing table: a three-drawer chest whose
// top is a guarded, slightly dished changing surface. It is built from the
// library's base_unit() — a carcass on a set-back toe-kick plinth under a thin top
// slab — the same body the filing cabinet and the kitchen run stand on, so it reads
// as furniture on the floor and not a box sunk into it.
//
// It used to carry its drawers as the drawers() pictogram engraved on the TOP face,
// the labelled-brick anti-pattern AGENTS.md §1.1 warns against: a 0.4 mm groove on
// the one face a low angle sees least of, on a piece whose whole front is drawers.
// They are on the FRONT (-Y) face now, where you pull them — real recessed fronts
// (unit_fronts()) with a pair of round knob dimples on each, the chest-of-drawers
// look that tells this from a fitted run at 1:40 (a kitchen is handleless).
//
// The top is what makes it a changing table rather than any other chest, so the top
// is where the real form went. A raised guard rim runs round all four edges — a
// self-tapering cushion() band, not a thin wall or a row of turned spindles, so it
// prints support-free and there is nothing fine enough to snap — and inside it the
// surface dishes into a shallow sink-style well (hollow(), walls sloping out), the
// contour a changing pad lies in. Rim above and well below, a person reads a tray a
// baby is kept from rolling off; there is no ink on the top at all.
//
// What it deliberately leaves off: standing knobs and safety-strap posts (a ~1 mm
// spike at 1:40 snaps off and catches on whatever the piece is stored with — the
// knobs are cut dimples), and any railing turned as separate bars (the guard is one
// tapering band).
//
// Width/Depth are the real-world footprint in cm — a changing chest is close to a
// dresser, about 80 wide by 50 deep. Height is the real height of the changing
// surface, waist height (about 90 cm) so a baby can be reached without stooping,
// shrunk by the plan scale like the footprint (see printed_h() in lib/common.scad);
// the guard rim stands its own real height on top of that.
//
// Prints the right way up with no supports: every step is vertical, a 45 deg flare
// or a self-tapering pad, the well is a sink that widens as it rises, and the magnet
// pocket opens at the bottom in the plinth — the footprint that really meets the
// board (unit_plinth_d()).

include <../lib/common.scad>

Width  = 80;  // cm
Depth  = 50;  // cm
Height = 90;  // cm — the changing surface

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The carcass, as a fitted unit: base_unit()'s thin top slab is the changing
// surface the guard rim and well sit on, in real cm (see Unit_* in lib/common.scad
// for the plinth's toe kick and the slab's lip).
Top_h = 4;  // cm of the height the top slab takes

// The drawers, on the FRONT (-Y) face: courses of fronts up the face, columns
// across, each recessed inside a shadow gap with round knob dimples — a chest of
// drawers, not the handleless grip rail a fitted kitchen reads by.
Show_drawers = true;
Drawers      = 3;  // courses of fronts up the face ...
Cols         = 1;  // ... and how many across
Knob_d       = 4;  // cm — a round drawer knob
Knobs        = 2;  // per front, as a dresser has

// The changing surface on top: a raised guard rim round the edges and a shallow
// dished well inside it.
Show_rim  = true;
Show_well = true;
// The guard rim: how far in from the edge the raised band reaches, in real cm, and
// how it is built. It reuses cushion()'s self-tapering hull — the sides slope, so it
// prints without support, unlike a thin tall wall — but with a smaller radius/taper
// than the Cushion_* defaults, which are sized for a full pillow and would collapse a
// band this narrow to nothing.
Rim_w      = 6;    // cm
Rim_h      = 8;    // cm the rim stands above the surface
Rim_taper  = 0.3;  // mm
Rim_radius = 0.3;  // mm
// The changing well: a shallow sink-style hollow dished into the surface, inset from
// each edge so it nests just inside the guard rim (leave Well_inset > Rim_w and a
// flat border is left between the two).
Well_depth = 6;    // cm the surface dishes down ...
Well_inset = 9;    // ... and cm from each edge to its rim, just inside Rim_w
Well_floor = 1.6;  // mm of base kept under the well, whatever the height

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep
// the piece from pivoting; they go in the plinth, the footprint that really meets the
// board (see unit_plinth_d() and Magnet_* in lib/common.scad). The 80 cm width is
// 20 mm at 1:40 — wide enough for the 4 mm disc.
Magnets = 2;

changing_table();

module changing_table() {
    union() {
        difference() {
            base_unit(Width, Depth, Print_h, Top_h);
            if (Show_drawers)
                unit_fronts(Width, Depth,
                            unit_face_z0(Width, Depth, Print_h, Top_h),
                            unit_face_z1(Width, Depth, Print_h, Top_h),
                            Cols, Drawers, Top_h,
                            knob_cm = Knob_d, knob_n = Knobs);
            if (Show_well) changing_well();
            if (Magnets > 0)
                magnets(Width, unit_plinth_d(Width, Depth), Magnets);
        }
        if (Show_rim) guard_rim();
    }
}

// The dished changing surface: a shallow sink-style hollow (see hollow() in
// lib/common.scad — the walls slope out on the way up, so it prints support-free and
// the render light reaches the floor instead of leaving a dark slot) sunk into the
// top and inset inside the guard rim. Its depth is clamped to leave Well_floor of
// base under it, and it says so when a short surface gives that up.
function well_w()  = Width - 2 * Well_inset;
function well_d()  = Depth - 2 * Well_inset;
function well_dz() = min(rise(Well_depth), max(0, Print_h - Well_floor));

module changing_well() {
    if (well_w() > 0 && well_d() > 0 && well_dz() > 0) {
        if (rise(Well_depth) > Print_h - Well_floor)
            echo(str("NOTE: a ", Well_depth, " cm changing well will not sink into a ",
                     Height, " cm surface over ", Well_floor, " mm of base — dished ",
                     rise_cm(well_dz()), " cm instead (give it more: CHANGING_TABLE_H)"));
        hollow(Print_h, well_dz()) footprint_2d(well_w(), well_d());
    } else {
        echo(str("NOTE: a ", Well_inset, " cm inset leaves no room for a changing well ",
                 "in a ", Width, "x", Depth, " cm top — well skipped (less: Well_inset)"));
    }
}

// The guard rim: four cushion()-style pads butted at the corners — two full-width
// bars along the front/back edges and two shorter bars along the sides, tiling a
// shallow raised frame around the top. Each pad is its own low, self-tapering hull
// (see cushion() in lib/common.scad), so the frame prints flat with no support,
// unlike a thin tall wall.
module guard_rim() {
    for (s = [-1, 1]) {
        translate([0, s * cm(Depth - Rim_w) / 2, 0])
            cushion(Width, Rim_w, Print_h, Rim_h, Rim_taper, Rim_radius);
        translate([s * cm(Width - Rim_w) / 2, 0, 0])
            cushion(Rim_w, Depth - 2 * Rim_w, Print_h, Rim_h, Rim_taper, Rim_radius);
    }
}
