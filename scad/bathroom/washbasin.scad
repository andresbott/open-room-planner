// bathroom / washbasin — a washbasin / vanity unit token: a real dished bowl
// recessed into the top face with a plughole in its floor, and the cabinet fronts
// drawn on the front face.
//
// The bowl is a proper basin, not a crater: the walls slope out on the way up
// from a small flat floor, the way bathtub.scad cuts its hollow. That flat floor
// is what gives the drain somewhere to sit — sunk into a point it would break
// out through the sloping wall — and it is what a basin looks like from above.
//
// A small faucet stands on the deck behind the bowl — a spout and two handle knobs — the same
// way bathtub.scad models its tap: as VERTICAL PRISMS standing off the deck, never a spout
// arching over the bowl. A real tap at 1:40 is a 1 mm spike over a hollow that will not print and
// snaps if it does (§1.3), but a prism up the print direction lands every layer on the one below,
// so the basin reads unmistakably as a basin — bowl in front, tap behind — and still prints clean.
//
// Width/Depth are the real-world footprint in cm. Standard European vanity
// widths run 40 (cloakroom), 50, 60 (standard single), 80 (roomy single) and
// 120–150 for a twin/double unit; depths run 35 (cloakroom/slimline), 40–45
// (compact) and 50 (full size). Height is the real counter height — a basin stands
// a little higher than a kitchen worktop — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad).
//
// Set Basins = 2 for a double vanity: the bowls are spread evenly across the
// width, each sized to its own half of the counter.

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 45;  // cm
Height = 85;  // cm — the counter

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Basins = 1;   // number of bowls: 1 (single) or 2 (double vanity)

Show_basin = true;
// Bowl size in real-world cm; 0 = derive a proportionate bowl from the counter
// (see bowl_w()/bowl_d()), so one file covers every size and both bowls of a
// double unit come out right without hand-tuning.
Basin_w = 0;  // cm, bowl width  (0 = auto)
Basin_d = 0;  // cm, bowl depth  (0 = auto), front to back
// How deep the bowl dishes down, real-world cm. A real basin bowl is ~12–16 cm;
// it is clamped at render time so a floor always remains under it whatever the
// scale or token height (see bowl_dz()).
Bowl_depth = 14;  // cm
Bowl_floor = 1.5; // printed mm — least material left under the deepest point
// The flat bottom of the bowl, as a fraction of the rim: the walls slope out
// from it to the full oval at the top face, so there is no overhang to print
// and the drain has something flat to sit on. Keep it generous — much under
// 0.6 and the bowl stops reading as a basin and starts reading as a funnel.
// 1 would give a straight-sided tub, 0 a crater with a point at the bottom.
Bowl_floor_ratio = 0.62;

// Deck kept around a DERIVED bowl, real-world cm: to each side, in front (room
// for the doors below) and behind (where a real basin has its tap and splashback,
// which is why the bowl sits forward of centre).
Bowl_side  = 8;   // cm
Bowl_front = 9;   // cm
Bowl_back  = 12;  // cm
// Bounds on a derived bowl, real-world cm, so a tiny cloakroom unit still gets a
// bowl and a wide one does not grow a trough.
Basin_w_min = 20;  Basin_w_max = 50;
Basin_d_min = 16;

// The drain: a countersunk hole in the flat floor of each bowl — printed mm, so
// it does not scale, and clamped to whatever the floor gives it (see drain_r()).
// A hole and not the engraved ring bathtub.scad uses for its drain: a basin floor
// is a couple of mm across, and a 0.4 mm line on it disappears both under a
// fingertip and in a photo, while a hole reads as a plughole from any angle. It
// widens upwards, so it prints like the bowl it sits in.
Show_drain = true;
Drain_r    = 0.7;   // mm, radius at the bowl floor
Drain_h    = 0.5;   // mm, how far it sinks below the floor
Drain_cone = 0.6;   // its bottom, as a fraction of the top — the sloping sides
                    // catch the light, so the hole reads as a hole

// The faucet on the deck behind each bowl — a spout and two handle knobs, the same vertical
// prisms bathtub.scad stands on its tap deck (see its header). Real cm: the rises scale like any
// height, the footprints like any plan dimension. Off -> the plain deck the part used to have.
Show_tap   = true;
Tap_h      = 12;  // cm the spout stands above the counter ...
Tap_w      = 3;   // ... its body this wide across (X) ...
Tap_reach  = 5;   // ... and this long toward the bowl (Y), so it reads as a spout, not a post
Handle_h   = 3;   // cm the two handle knobs stand — low, so the spout dominates ...
Handle_d   = 3;   // ... each this wide ...
Handle_gap = 12;  // ... the two of them this far apart (X, centre to centre), flanking the spout

// The cabinet, drawn on the FRONT FACE — the one place on this token where the
// cabinet is actually visible, and the only one with room for it. Looking down on
// a real vanity you see a counter and a bowl and nothing else; the doors are under
// the overhang. So the front face gets a line where the counter slab
// meets the carcass, and a seam at every division between two door fronts, which
// is what you see standing in front of one — and what a photo taken from a low
// angle catches. The 45 cm-deep counter only leaves 9 cm (2.25 mm printed) of
// deck in front of the bowl, not enough to draw fronts on and count them.
Show_doors  = true;
Doors       = 0;    // door fronts per basin (0 = auto, see door_count())
Door_width  = 35;   // cm, nominal width of one door front
Door_seam_w = 2.4;  // cm, seam between two fronts — >= one nozzle when cut
// The counter slab and the plinth under the doors are real cm — a slab and a
// recessed base of a given thickness, however big the unit; the wall left at a
// rounded corner is a print detail and stays printed mm.
Counter_h    = 4;    // cm of the front face the counter slab takes
Plinth_h     = 10;   // cm ... and how much is left plain under the doors
Front_margin = 1.0;  // printed mm the counter line stops short of the side corners

// Magnet pockets in the bottom face, in a row along the width (0 = none). A
// single vanity's 60 cm width is 15 mm at 1:40 — room for one 4 mm disc; a
// double unit is wider and takes the row the count asks for.
Magnets = 1;

// ---- derived bowl geometry --------------------------------------------------
// The counter split between bowls, and a bowl sized to fill its share with the
// decks above kept clear.
function per_width() = Width / Basins;
function bowl_w() = Basin_w > 0 ? Basin_w
    : max(Basin_w_min, min(Basin_w_max, per_width() - 2 * Bowl_side));
function bowl_d() = Basin_d > 0 ? Basin_d
    : max(Basin_d_min, Depth - Bowl_front - Bowl_back);
// Bowl centre, in real-world cm from the counter centre: forward enough to keep
// Bowl_back of deck behind it; spread evenly across the width.
function bowl_cy()  = Depth / 2 - Bowl_back - bowl_d() / 2;
function bowl_cx(i) = -Width / 2 + per_width() * (i + 0.5);
// Bowl dish depth in printed mm, clamped so a floor (magnet pocket, wall, and
// the drain sunk into it) always remains under the deepest point.
function bowl_dz(top_z) =
    max(0.5, min(rise(Bowl_depth),
                 top_z - magnet_pocket_h() - Bowl_floor
                       - (Show_drain ? Drain_h : 0)));
// The drain, printed mm: as wide as asked for, or as wide as the flat floor can
// take with a wall kept between it and the foot of the sloping side.
function bowl_floor_min() = min(cm(bowl_w()), cm(bowl_d())) * Bowl_floor_ratio;
function drain_r() = min(Drain_r, bowl_floor_min() / 2 - Symbol_stroke);
// The deck behind the bowl has room for the faucet: its reach plus a margin fits between the
// bowl's back rim and the counter's back edge.
function tap_fits() = (Depth / 2 - (bowl_cy() + bowl_d() / 2)) >= Tap_reach + 3;

washbasin();

module washbasin() {
    union() {
        difference() {
            footprint(Width, Depth, Print_h);
            if (Show_basin)
                for (i = [0 : Basins - 1]) {
                    bowl(bowl_cx(i), bowl_cy(), Print_h);
                    // a hole narrower than the nozzle is not worth cutting
                    if (Show_drain && drain_r() > Symbol_stroke)
                        drain(bowl_cx(i), bowl_cy(), Print_h);
                }
            if (Show_doors)
                doors(Print_h);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_tap) {
            if (tap_fits())
                for (i = [0 : Basins - 1]) tap(bowl_cx(i), Print_h);
            else
                echo(str("NOTE: only ", Depth / 2 - (bowl_cy() + bowl_d() / 2),
                         " cm of deck behind the bowl — too little for the ", Tap_reach,
                         " cm faucet, left off (give it more depth, or a smaller Bowl_back)"));
        }
    }
}

// The faucet, standing on the deck behind a bowl at <cx>: a spout — a stadium vertical prism
// elongated toward the bowl (−Y), so it reads as a spout and not a post — and two handle knobs
// flanking it. All stand off the counter as vertical prisms, buried a hair into it so they weld
// solid; nothing arches over the bowl, so nothing overhangs (see the header). The spout's foot
// lands on the solid deck behind the bowl, clear of the hollow.
module tap(cx, top_z) {
    back_edge = bowl_cy() + bowl_d() / 2;         // the bowl's +Y rim, real cm
    cy_spout  = back_edge + Tap_reach / 2 + 1;    // just behind the bowl, on the deck
    gap = min(Handle_gap, per_width() - Handle_d - 2);   // keep both knobs on this bowl's share
    translate([cm(cx), cm(cy_spout), top_z - rise(2)])
        linear_extrude(height = rise(Tap_h) + rise(2))
            hull() for (sy = [-1, 1])
                translate([0, sy * cm(Tap_reach - Tap_w) / 2]) circle(d = cm(Tap_w));
    for (s = [-1, 1])
        translate([cm(cx) + s * cm(gap) / 2, cm(cy_spout), top_z - rise(2)])
            cylinder(h = rise(Handle_h) + rise(2), d = cm(Handle_d));
}

// A real dished bowl carved into the top face: an oval rim narrowing to a small
// flat floor, cut as a hull between the two so the walls slope out on the way up
// — no overhang for the printer, and the light gets into the hollow instead of
// leaving a dark slot. The cut runs a hair over the top face, so the rim comes
// out clean. Subtract it from the solid.
module bowl(cx, cy, top_z) {
    dz = bowl_dz(top_z);
    translate([cm(cx), cm(cy), 0])
        hull() {
            translate([0, 0, top_z - dz])
                linear_extrude(height = 0.01)
                    scale(Bowl_floor_ratio) footprint_oval_2d(bowl_w(), bowl_d());
            translate([0, 0, top_z])
                linear_extrude(height = 0.01)
                    footprint_oval_2d(bowl_w(), bowl_d());
        }
}

// The drain: a countersunk hole in the middle of the bowl's flat floor, sunk
// Drain_h below it and narrowing on the way down. The cut runs a hair above the
// floor, so its rim comes out clean — the same trick bowl() uses at the top face.
module drain(cx, cy, top_z) {
    r = drain_r();
    translate([cm(cx), cm(cy), top_z - bowl_dz(top_z) - Drain_h])
        cylinder(h = Drain_h + 0.01, r1 = r * Drain_cone, r2 = r);
}

// How many door fronts the unit has: as asked for, or one per Door_width cm of
// each basin's share of the counter — so a 40 cm cloakroom unit gets a single
// door, a 60 or 80 cm one a pair, and a double vanity a pair per bowl.
function door_count() = Doors > 0 ? Doors * Basins
                                 : Basins * max(1, round(per_width() / Door_width));

// The cabinet on the front face: the counter slab line across the width, and a
// seam from it down to the plinth at every division between two door fronts.
module doors(top_z, depth = Label_depth) {
    n  = door_count();
    pz = rise(Plinth_h);                                          // top of the plinth
    cz = max(pz + cm(Door_seam_w), top_z - rise(Counter_h));    // under the counter
    w  = cm(Width) - 2 * Front_margin;   // clear of both rounded corners
    if (w > cm(Door_seam_w))
        front_cut(0, w, cz, cm(Door_seam_w), depth);
    if (n > 1)
        for (i = [1 : n - 1])
            front_cut(cm(-Width / 2 + Width * i / n), cm(Door_seam_w),
                      (pz + cz) / 2, cz - pz, depth);
}

// A rectangle cut <depth> mm into the front (-Y) face: <w> x <h> printed mm,
// centred on <cx>,<cz> from the centre of that face's width and the bottom of
// the piece. The counterpart of groove() for the one face that is not the top.
module front_cut(cx, w, cz, h, depth = Label_depth) {
    translate([cx, -cm(Depth) / 2 + (depth - 0.01) / 2, cz])
        cube([w, depth + 0.01, h], center = true);
}
