// outdoor / planter — a plant pot / planter: a tapered pot with a real hollow in it, round by
// default (a square Width/Depth variant is also supported).
//
// It used to be a straight-sided block with a rim ring and a soil circle engraved on top —
// two 0.4 mm lines standing in for the one thing that makes a pot a pot, which is that you can
// see into it. The inside is now a real hollow (hollow() in lib/common.scad, the same cut a
// basin and a sink bowl get): what is left standing round it is the pot's lip, and the flat
// floor at the bottom of it is the soil. The outside tapers in towards the base as a real pot
// does, so the piece reads as a pot from the side as well as from above.
//
// Both shapes print the right way up with nothing to support: the taper leans out about 6 deg
// on the way up, and the hollow's walls slope out with it, so every layer lands on the one
// below.
//
// Diameter (round pots, Round = true) or Width/Depth (square pots, Round = false) is the
// real-world footprint in cm — the RIM, which is the widest part and so the space the pot takes
// on the plan — and Height the pot's real height, about as tall as it is wide for a plain pot,
// shrunk by the plan scale like the footprint (see printed_h() in lib/common.scad). A tall
// floor-standing tree planter is the same part at Height = 80 or more.

include <../lib/common.scad>

Round    = true;  // true -> a round pot of Diameter; false -> a square Width/Depth one
Diameter = 40;    // cm, round pots only — the rim
Width    = 40;    // cm, square pots only
Depth    = 40;    // cm, square pots only
Height   = 40;    // cm — a plain pot (80+ for a tree planter)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// How much narrower the base is than the rim, in real cm — the pot's taper, total across the
// piece. A real pot loses about a fifth of its width on the way down; it is clamped in base_w()
// so the foot always stays wide enough to stand on and to bury a magnet.
Taper = 8;

Show_soil = true;
// The hollow, in real cm: the lip left standing round it, and how far down the soil sits. It is
// clamped to whatever the pot's height leaves over a magnet pocket — see soil_dz(), which warns
// when it had to give any of it back, as bathtub.scad does.
Rim_w      = 3;    // cm of lip left round the hollow
Soil_depth = 20;   // cm down to the soil
Soil_floor = 1.2;  // printed mm of material kept under it, over a magnet pocket
Soil_r     = 1;    // printed mm, corner rounding of a square pot's hollow

// Magnet pockets in the bottom face (0 = none). One central pocket: a pot is small and round or
// near-square, nothing to pivot on the board. It is measured on the BASE, not the rim, since the
// base is what touches the board — a 40 cm pot tapers to 32, which is 8 mm at 1:40 and still
// room for the 4 mm disc (see Magnet_* in lib/common.scad).
Magnets = 1;

// ---- the pot, and what fits in it -------------------------------------------
function rim_w() = Round ? Diameter : Width;
function rim_d() = Round ? Diameter : Depth;
// The base: the rim less the taper, but never so narrow that it cannot bury a magnet pocket or
// stand up on its own.
function base_min() = Magnets > 0 ? magnet_span_cm() : 0;
function taper()    = max(0, min(Taper, min(rim_w(), rim_d()) - base_min()));
function base_w()   = rim_w() - taper();
function base_d()   = rim_d() - taper();
// The hollow: the rim less its lip, and how deep it really goes — what is left of the height
// once the floor, and a magnet pocket under it, have had their share.
function soil_w() = max(0, rim_w() - 2 * Rim_w);
function soil_d() = max(0, rim_d() - 2 * Rim_w);
function soil_under() = magnet_count(base_w(), base_d(), Magnets) > 0
                            ? magnet_pocket_h() : 0;
function soil_dz() = max(0, min(rise(Soil_depth),
                                Print_h - soil_under() - Soil_floor));
// A square hollow's corner rounding, clamped so a small one cannot be rounded away to nothing.
function soil_r() = max(0, min(Soil_r, min(cm(soil_w()), cm(soil_d())) / 2 - 0.05));

planter();

module planter() {
    if (Show_soil && soil_dz() < rise(Soil_depth) - 0.001)
        echo(str("WARNING: a ", Soil_depth, " cm hollow does not fit in a ", Height,
                 " cm pot over ", soil_under(), " mm of magnet pocket — sunk ",
                 rise_cm(soil_dz()), " cm instead (give it more: PLANTER_H)"));
    difference() {
        pot();
        if (Show_soil && soil_w() > 0 && soil_d() > 0)
            hollow(Print_h, soil_dz()) outline_2d(soil_w(), soil_d(), soil_r());
        if (Magnets > 0)
            magnets(base_w(), base_d(), Magnets);
    }
}

// The pot: a hull from the base outline at the floor out to the full rim at the top, so the
// sides lean out at a few degrees all the way up instead of stepping.
module pot() {
    hull() {
        linear_extrude(height = 0.01) outline_2d(base_w(), base_d());
        translate([0, 0, Print_h - 0.01])
            linear_extrude(height = 0.01) outline_2d(rim_w(), rim_d());
    }
}

// The pot's outline at <w_cm> x <d_cm>, round or square — the body, the base and the hollow all
// come out of the same call, as tub_2d() does in bathroom/bathtub.scad.
module outline_2d(w_cm, d_cm, r = Corner_radius) {
    if (Round) footprint_round_2d(w_cm);
    else       footprint_2d(w_cm, d_cm, r);
}
