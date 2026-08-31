// hallway / shoe_cabinet — a shallow tilt-out shoe cabinet: a wide, shallow carcass on a
// set-back toe kick, its three tilt-out flap fronts recessed into the FRONT (-Y) face, each
// with a finger-pull grip cut along its top edge where you tip it open. A thin top lid caps
// the carcass and overhangs the flaps at the front, so the top line reads from the side.
//
// It used to be the labelled brick AGENTS.md §1.1 warns against: a plain footprint() box with
// the flap seams engraved as two hairlines on its TOP face — the one face a photograph of the
// plan sees least of, where a 0.4 mm groove says nothing under a fingertip. A shoe cabinet's
// flaps are on its front, where you tilt them out, so that is where they went — real recessed
// panels over a toe kick, the same upgrade office/filing_cabinet.scad had from its own
// top-engraved box, built on the fitted-unit body the kitchen carcasses stand on.
//
// The pull is the handleless finger grip unit_fronts() cuts along the top of each front, not a
// knob: a tilt-out flap is opened by hooking its top edge, a cut reads truer than the 1 mm
// knob that would snap off in the box (§1.3), and the wide, low flaps — a ~96 x 29 cm panel,
// far wider than a filing drawer's near-square front — are what tell this shallow cabinet from
// the deeper carcasses it shares the fitted-unit look with (§1.4).
//
// PRINTS THE RIGHT WAY UP, no supports: every step out on the way up is a 45 deg flare
// (plinth -> carcass -> top lid), each flap recess is a short ceiling in a vertical face, and
// the magnet pocket opens at the floor, in the plinth.
//
// The toe kick is set back only Toe_kick = 4 cm, shallower than the kitchen's 6 cm (Unit_kick),
// on purpose: a shoe cabinet is only Depth = 30 cm deep, and a 6 cm kick would leave a 24 cm
// plinth — 6.0 mm at 1:40, just under the 6.3 mm a 4 mm magnet disc needs to bury
// (magnet_min_span). At 4 cm the plinth stays 26 cm (6.5 mm) and keeps the strong disc, while
// still reading as a real toe kick in shadow at the floor.
//
// Width/Depth are the real-world footprint in cm: a hallway shoe cabinet runs wide and shallow
// along a wall, 100 cm wide, 30 cm deep. Height is the real carcass height — three flaps up to
// about hip height — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad). The FRONT is the -Y edge; +Y is the wall side and stays flush, so the
// piece butts against the wall and against its neighbours.

include <../lib/common.scad>

Width  = 100;  // cm
Depth  = 30;   // cm — shallow: shoes stored angled behind a tilt-out flap
Height = 100;  // cm — three flaps high

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The top lid, in real cm — a thin cap over the flaps, standing a little proud at the front
// so the piece has a top surface (keys, post) rather than a flap running off the top edge.
Top_h = 4;

// The toe kick (plinth set-back), real cm. Held shallower than the set's Unit_kick so the
// plinth it leaves stays wide enough to bury the standard magnet disc under a 30 cm-deep
// piece — see the header. Clamped below so a deeper Depth override cannot starve the disc.
Toe_kick = 4;

Show_fronts = true;
Flaps       = 3;  // tilt-out flap fronts stacked up the front face

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep this wide
// piece from pivoting on the board; see Magnet_* in lib/common.scad. They go in the plinth —
// the footprint that really meets the board (unit_plinth_d's idea) — and the row is shifted
// onto the plinth's centre, since the plinth is set back at the front only.
Magnets = 2;

// ---- derived geometry -------------------------------------------------------
// The toe kick actually cut: what was asked for, but never so deep that the plinth it leaves
// is too thin across to hold the magnet disc (magnet_min_span, back in real cm via plan_cm).
function toe_kick() = max(0, min(Toe_kick, Depth - plan_cm(magnet_min_span(Magnet_d))));
function plinth_d() = Depth - toe_kick();

// The slab / carcass / plinth stack, mirroring base_unit() but with the shallower kick above.
// over is the top lid's front overhang (the lip); foot and slab are each capped at a third of
// the room the two flares leave, so a squashed piece still comes out solid, never inside out.
function sc_over()    = min(Unit_lip, toe_kick());
function sc_room()    = max(0, Print_h - cm(toe_kick()));
function sc_foot()    = min(rise(Unit_foot), sc_room() / 3);
function sc_slab()    = Top_h > 0 ? min(rise(Top_h), sc_room() / 3) : 0;
// The band of carcass face the flaps go in, printed mm up from the floor, and the depth to
// hand unit_fronts() so its cut lands on the carcass face and not out at the footprint edge.
function sc_face_z0() = sc_foot() + cm(toe_kick() - sc_over());
function sc_face_z1() = Print_h - sc_slab() - cm(sc_over());
function sc_face_d()  = Depth - 2 * sc_over();

if (Magnets > 0 && toe_kick() < Toe_kick)
    echo(str("NOTE: a ", Toe_kick, " cm toe kick would leave too thin a plinth to bury a ",
             Magnet_d, " mm disc in a ", Depth, " cm deep cabinet — cut it to ",
             toe_kick(), " cm instead (give it more depth: DEPTH)"));

shoe_cabinet();

module shoe_cabinet() {
    difference() {
        shoe_carcass();
        // the three flaps: wide recessed panels, one column by Flaps rows, each with the
        // finger-pull grip slot unit_fronts() cuts along its top — where a tilt-out flap opens
        if (Show_fronts)
            unit_fronts(Width, Depth, sc_face_z0(), sc_face_z1(),
                        1, Flaps, face_cm = sc_face_d());
        // pockets in the plinth, the face that meets the board; the plinth is set back at the
        // front only, so shift the row onto its centre to keep the disc's wall all round
        if (Magnets > 0)
            translate([0, cm(toe_kick()) / 2, 0])
                magnets(Width, plinth_d(), Magnets);
    }
}

// The body: a set-back plinth, a 45 deg flare out to the carcass (itself set back for the
// lid's lip), the carcass, another flare out to a top lid at the full footprint — base_unit()'s
// support-free stack, rebuilt here only so the toe kick can be the shallower one above.
module shoe_carcass() {
    kick = toe_kick();
    over = sc_over();
    foot = sc_foot();
    slab = sc_slab();
    z0   = sc_face_z0();
    z1   = sc_face_z1();
    union() {
        linear_extrude(height = foot + 0.01)               // the plinth (toe kick)
            footprint_front_2d(Width, Depth, kick);
        if (kick > over)                                   // flare out to the carcass
            translate([0, 0, foot])
                flare(cm(kick - over)) {
                    footprint_front_2d(Width, Depth, kick);
                    footprint_front_2d(Width, Depth, over);
                }
        translate([0, 0, z0])                              // the carcass, the flaps' face
            linear_extrude(height = max(0.01, z1 - z0))
                footprint_front_2d(Width, Depth, over);
        if (over > 0)                                      // flare out to the top lid
            translate([0, 0, z1])
                flare(cm(over)) {
                    footprint_front_2d(Width, Depth, over);
                    footprint_2d(Width, Depth);
                }
        if (slab > 0)                                      // the top lid
            translate([0, 0, Print_h - slab])
                linear_extrude(height = slab) footprint_2d(Width, Depth);
    }
}
