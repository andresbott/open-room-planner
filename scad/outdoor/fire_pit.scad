// outdoor / fire_pit — a wood-burning fire pit: a low tapered bowl with a real hollow, and a
// stack of logs standing in it. It is the planter's close cousin (outdoor/planter.scad) — the
// same tapered body and the same sunken hollow (hollow() in lib/common.scad, the cut a basin
// and a plant pot share) — and it has to be, because a bare bowl on the plan is a bowl: what
// tells a fire pit from a big plant pot is the LOGS in it, a criss-cross of raised bars on the
// hollow floor the way a campfire is laid, seen from straight above. That is the recognisable
// thing, so it is real relief and not an engraved flame: a 0.4 mm scribble of fire would
// vanish in a photo, while bars that stand a few cm proud catch the light and read as a fire
// laid ready to light.
//
// No flames and no spikes: a tongue of flame modelled proud would be a thin point that snaps
// off (§1.3), so the fire is the fuel, not the burn. The logs are low prisms rising straight
// from the bowl floor, so every layer lands on the one below and the piece prints the right way
// up with nothing to support — the taper leans out a few degrees, the hollow's walls slope out,
// and the logs stand vertically inside it.
//
// Diameter (round, Round = true) or Width/Depth (square, Round = false) is the real-world rim
// in cm — the widest part, so the footprint the pit takes on the plan — and Height its real
// height, a low bowl (a fire pit sits far lower than a plant pot), shrunk by the plan scale
// (see printed_h() in lib/common.scad). Like the planter and the shower tray, the bowl is
// clamped to whatever the height leaves over a magnet pocket and warns in the render log when
// it had to give any of it back — so a very shallow pit is a FIRE_PIT_H away.

include <../lib/common.scad>

Round    = true;  // true -> a round pit of Diameter; false -> a square Width/Depth one
Diameter = 70;    // cm, round pits only — the rim
Width    = 70;    // cm, square pits only
Depth    = 70;    // cm, square pits only
Height   = 45;    // cm — a low bowl

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// How much narrower the base is than the rim, in real cm — the bowl's taper, total across the
// piece. Clamped in base_w() so the foot stays wide enough to stand on and to bury a magnet.
Taper = 10;

Show_fire = true;
// The bowl, in real cm: the rim (metal edge) left standing round the hollow, and how far down
// it goes. Clamped to what the height leaves over a magnet pocket — see bowl_dz(), which warns
// when it had to give any back, as planter.scad does.
Rim_w      = 5;    // cm of rim left round the hollow
Bowl_depth = 22;   // cm down to the bottom of the bowl
Bowl_floor = 1.2;  // printed mm of material kept under it, over a magnet pocket
Bowl_r     = 1;    // printed mm, corner rounding of a square bowl's hollow

// The logs laid in the bowl: a criss-cross of raised bars on the floor, like a log-cabin fire
// lay seen from above. Real cm, because they are fuel and not ink.
Logs   = 4;    // bars in the stack (a pair each way, offset from the centre) ...
Log_w  = 7;    // ... each this wide ...
Log_h  = 11;   // ... standing this high off the bowl floor (kept below the rim) ...
Log_gap = 9;   // ... and this far off the centre line, so they cross in a square not a point

// Magnet pockets in the bottom face (0 = none). One central pocket: a pit is small and round or
// near-square, nothing to pivot on the board. Measured on the BASE (what touches the board),
// not the rim — a 70 cm pit tapers to 60, which is 15 mm at 1:40, ample for the 4 mm disc.
Magnets = 1;

// ---- the bowl, and what fits in it ------------------------------------------
function rim_w() = Round ? Diameter : Width;
function rim_d() = Round ? Diameter : Depth;
function base_min() = Magnets > 0 ? magnet_span_cm() : 0;
function taper()    = max(0, min(Taper, min(rim_w(), rim_d()) - base_min()));
function base_w()   = rim_w() - taper();
function base_d()   = rim_d() - taper();
function bowl_w()   = max(0, rim_w() - 2 * Rim_w);
function bowl_d()   = max(0, rim_d() - 2 * Rim_w);
function bowl_under() = magnet_count(base_w(), base_d(), Magnets) > 0
                            ? magnet_pocket_h() : 0;
function bowl_dz()  = max(0, min(rise(Bowl_depth),
                                 Print_h - bowl_under() - Bowl_floor));
// A square bowl's corner rounding, clamped so a small one is not rounded away to nothing.
function bowl_r()   = max(0, min(Bowl_r, min(cm(bowl_w()), cm(bowl_d())) / 2 - 0.05));
// How high the logs may stand: what was asked for, but never up past the rim.
function log_h()    = max(0, min(rise(Log_h), bowl_dz() - Label_depth));

fire_pit();

module fire_pit() {
    if (Show_fire && bowl_dz() < rise(Bowl_depth) - 0.001)
        echo(str("WARNING: a ", Bowl_depth, " cm bowl does not fit in a ", Height,
                 " cm pit over ", bowl_under(), " mm of magnet pocket — sunk ",
                 rise_cm(bowl_dz()), " cm instead (give it more: FIRE_PIT_H)"));
    union() {
        difference() {
            bowl();
            if (Show_fire && bowl_w() > 0 && bowl_d() > 0)
                hollow(Print_h, bowl_dz()) outline_2d(bowl_w(), bowl_d(), bowl_r());
            if (Magnets > 0)
                magnets(base_w(), base_d(), Magnets);
        }
        if (Show_fire && log_h() > 0) logs();
    }
}

// The bowl: a hull from the base outline at the floor out to the full rim at the top, so the
// sides lean out a few degrees all the way up instead of stepping (the planter's body).
module bowl() {
    hull() {
        linear_extrude(height = 0.01) outline_2d(base_w(), base_d());
        translate([0, 0, Print_h - 0.01])
            linear_extrude(height = 0.01) outline_2d(rim_w(), rim_d());
    }
}

// The logs: a pair of bars each way, offset from the centre so they cross in a square (a
// log-cabin lay), standing on the bowl floor and clipped to the hollow so none pokes through
// the bowl wall. Added to the solid after the hollow is cut, so they stand up inside it.
module logs() {
    fz  = Print_h - bowl_dz();                          // the bowl floor
    n   = max(2, Logs - Logs % 2);                      // bars come in pairs
    translate([0, 0, fz])
        linear_extrude(height = log_h())
            intersection() {
                log_bars_2d(n);
                offset(delta = -cm(Rim_w / 2)) outline_2d(bowl_w(), bowl_d(), bowl_r());
            }
}

// The bars, in 2D: half of them run one way and half the other, each set spread symmetrically
// about the centre Log_gap apart, so they cross in a square (a "#" for four logs, a denser grid
// for six). Long enough to reach across; the caller clips them to the bowl.
module log_bars_2d(n) {
    reach = cm(max(rim_w(), rim_d()));
    per   = floor(n / 2);                       // bars per direction
    for (dir = [0, 1], k = [0 : per - 1]) {
        p = per > 1 ? (k - (per - 1) / 2) * cm(Log_gap) : 0;
        if (dir == 0) translate([0, p]) square([reach, cm(Log_w)], center = true);
        else          translate([p, 0]) square([cm(Log_w), reach], center = true);
    }
}

// The bowl's outline at <w_cm> x <d_cm>, round or square — body, base, bowl and logs all come
// out of the same call, as in planter.scad.
module outline_2d(w_cm, d_cm, r = Corner_radius) {
    if (Round) footprint_round_2d(w_cm);
    else       footprint_2d(w_cm, d_cm, r);
}
