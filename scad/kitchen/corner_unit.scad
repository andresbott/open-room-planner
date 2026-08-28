// kitchen / corner_unit — the base unit that turns a corner: two arms of worktop run
// meeting at right angles, so an L or a U kitchen can actually be laid out. Without it a
// run can only ever go in a straight line, which is the one thing a real fitted kitchen
// never does.
//
// It is two base_unit() bodies unioned at right angles — one along X with its back at +Y,
// one along Y with its back at +X — and that union is what makes the piece work. base_unit()
// steps only its own front, so the two together come out with the worktop overhanging and
// the plinth set back on BOTH faces that look into the room, while the two open ENDS stay
// flush for the next length of run to butt against. Neither the slab nor the toe kick has a
// seam across it where the arms meet.
//
// In plan, with the walls at +X and +Y (the front of each arm is the face that looks into
// the room, so this piece has two of them):
//
//     +Y  ┌──────────────────┐        Width  — the length of the arm along X
//         │                  │        Depth  — the length of the arm along Y
//         │   ┌──────────────┤        Arm    — how deep each arm is, both the same
//         │   │              │
//         │   │   the notch  │  +X    the notch is (Width - Arm) x (Depth - Arm):
//         └───┤   is open    │        the open floor in the corner of the room
//             │   floor      │
//             └──────────────┘
//
// Each arm carries ONE DOOR on its exposed leg, not the drawer pairs of worktop.scad: a
// corner unit is a carousel behind a single door, and that door is what tells the corner
// from a length of run meeting it. The leg is the part of an arm that is not buried in the
// corner — 30 cm of it on the standard 90x90 unit, which is exactly one door.
//
// Width/Depth are the real-world lengths of the two arms in cm and Arm their depth: the
// standard corner base unit is 90x90 with 60 cm arms (a 120x120 corner leaves a 60x60 notch
// and takes a wider door on each arm). Height is the real worktop height — the same 90 cm
// counter as the rest of the kitchen — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so the corner comes out level with the run either side.
//
// It prints the right way up like every other unit: every step outwards on the way up is one
// of base_unit()'s 45 deg flares, and the magnet pockets open at the plinth, in the floor.

include <../lib/common.scad>

Width  = 90;  // cm — the arm along X
Depth  = 90;  // cm — the arm along Y
Arm    = 60;  // cm — how deep each arm is: the standard base-cabinet depth
Height = 90;  // cm — standard worktop height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The worktop slab, real cm — the same slab as the run it turns (see worktop.scad), so the
// lip line carries round the corner without a step.
Slab = Unit_top;

Show_doors = true;

// Magnet pockets in the bottom face (0 = none). An L has three places to put one — the
// plinth under each arm's exposed leg, and the solid square of plinth in the corner where
// the two arms overlap — so the count picks a layout rather than a row:
//   1  the corner square, the broadest piece of bottom face and the nearest to the
//      centre of gravity;
//   2  one under each arm's leg, corner to opposite corner, which is what stops an L
//      pivoting on the board — the default;
//   3  all three.
// A leg is only (Width - Arm) cm long, so on a plan much smaller than 1:40 it stops being
// able to hold a disc at all; pockets() falls back to the corner square and says so.
Magnets = 2;

corner_unit();

// Arm depth, clamped so a leg is always left for a door and a pocket: an Arm as deep as the
// piece is long would leave no notch, and the "corner" would be a plain square block.
function arm_d() = min(Arm, min(Width, Depth) * 3 / 4);
// The exposed leg of each arm — the part that is not buried in the corner, in real cm.
function leg_a() = Width - arm_d();
function leg_b() = Depth - arm_d();

module corner_unit() {
    if (arm_d() < Arm)
        echo(str("WARNING: a ", Arm, " cm arm leaves no leg on a ", Width, "x", Depth,
                 " cm corner — cut back to ", arm_d(), " cm (give it longer arms: ",
                 "Width/Depth)"));
    difference() {
        union() {
            place_a() base_unit(Width, arm_d(), Print_h, Slab);
            place_b() base_unit(Depth, arm_d(), Print_h, Slab);
        }
        if (Show_doors) {
            place_a() arm_door(Width, leg_a());
            place_b() arm_door(Depth, leg_b());
        }
        if (Magnets > 0) pockets();
    }
}

// The two arms' frames. Everything an arm carries goes inside one of these, so a body, its
// door and its pocket can never drift apart: arm A lies along X with its back at +Y, arm B
// is the same unit turned a quarter turn so its own front points at -X.
module place_a() {
    translate([0, cm(Depth / 2 - arm_d() / 2), 0]) children();
}
module place_b() {
    translate([cm(Width / 2 - arm_d() / 2), 0, 0]) rotate([0, 0, -90]) children();
}

// One arm's door, in that arm's own frame: a single front on the exposed leg, at the end
// away from the corner. unit_fronts() centres its grid, so the whole call is moved onto the
// leg — and it is handed the arm's real face depth, because the grid it is filling
// (<leg_cm> wide) is narrower than the body the cut has to land on (<len_cm>).
module arm_door(len_cm, leg_cm) {
    a = arm_d();
    translate([cm(-len_cm / 2 + leg_cm / 2), 0, 0])
        unit_fronts(leg_cm, a,
                    unit_face_z0(len_cm, a, Print_h, Slab),
                    unit_face_z1(len_cm, a, Print_h, Slab),
                    1, 1, Slab, face_cm = unit_face_d(len_cm, a, Slab));
}

// Which of the three sites get a pocket (see Magnets above), and the fallback for a plan
// too small for a leg to hold one.
module pockets() {
    n  = min(Magnets, 3);
    ok = magnet_count(leg_a(), unit_plinth_d(Width, arm_d()), 1) > 0
      && magnet_count(leg_b(), unit_plinth_d(Depth, arm_d()), 1) > 0;
    if (Magnets > 3)
        echo(str("NOTE: a corner unit has three pocket sites — one under each arm and one ",
                 "in the corner; ", Magnets, " asked for, 3 cut"));
    if (!ok) {
        echo(str("NOTE: a ", leg_a(), " x ", leg_b(), " cm pair of arm legs at 1:", Scale,
                 " is too small to hold a pocket — ", n,
                 " asked for, one cut in the corner square instead"));
        corner_pocket();
    } else if (n == 1) {
        corner_pocket();
    } else {
        place_a() arm_pocket(Width, leg_a());
        place_b() arm_pocket(Depth, leg_b());
        if (n >= 3) corner_pocket();
    }
}

// A pocket under one arm's leg, in that arm's own frame. The footprint handed to magnets()
// is the plinth's and not the carcass's — the plinth is what touches the board — which is
// also why it is shifted back half the toe kick, to sit in the middle of it.
module arm_pocket(len_cm, leg_cm) {
    a = arm_d();
    translate([cm(-len_cm / 2 + leg_cm / 2), cm(unit_back(len_cm, a)) / 2, 0])
        magnets(leg_cm, unit_plinth_d(len_cm, a), 1);
}

// A pocket in the corner square: where the two arms' plinths overlap, in the +X+Y corner
// against the walls, which is the broadest solid piece of the bottom face.
module corner_pocket() {
    a  = arm_d();
    ba = unit_back(Width, a);   // the toe kick eaten off arm A's plinth ...
    bb = unit_back(Depth, a);   // ... and off arm B's
    translate([cm(Width / 2 - (a - bb) / 2), cm(Depth / 2 - (a - ba) / 2), 0])
        magnets(a - bb, a - ba, 1);
}
