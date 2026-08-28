// livingroom / armchair — a chunky boxy tub/club chair: thick squared arms and a thick
// VERTICAL back wrapping into a U around a seat cushion, the whole box standing up on
// four short legs. It used to be the sofa's soft one-seat sibling (a reclined back, thin
// arms, a throw pillow); this is a different, boxier animal on purpose — a solid cube of
// a chair, which is what tells it apart from the sofa on the plan and matches a low-poly
// club chair.
//
// In section, across the chair (front -Y on the left):
//
//        |‾‾‾‾‾‾|        the thick vertical back, full width so it wraps the arms ...
//     ___|  __  |        ... the arms, a step lower, and a soft seat cushion in the well
//    |   | /  \ |            between them ...
//    |   |/____\|__      ... a solid seat body ...
//    |  /          \     ... a 45 deg flare down to ...
//    |_|            |_|  ... four short corner legs, the skirt between them set back
//
// Why it is shaped this way: a tub chair reads by its bulk and its legs, not by ink, so
// the arms and back are real chunky blocks and the legs are a real frame — the corner
// posts stand at the footprint with the skirt set back behind them (legged_2d in
// lib/common.scad), so from any side you read four legs and it still prints straight up
// with nothing to bridge (the skirt runs to the floor; the only overhang is the 45 deg
// flare up to the seat body). No thin metal legs like a catalogue photo: a leg at 1:40 is
// a 1 mm spike that snaps off, so the token gets the frame instead. The back is vertical
// — a boxy chair's is, and a vertical wall is nothing for the printer. No throw pillow by
// default: the boxy seat reads clean, the way the reference does (Show_pillows for one).
//
// Width/Depth are the real-world footprint in cm. The heights are real cm too: Height is
// the top of the back, Arm the top of the arms and Seat the platform the legs carry and
// the cushion rises from (see printed_h() / rise() in lib/common.scad).

include <../lib/common.scad>

Width  = 80;  // cm
Depth  = 80;  // cm
Height = 80;  // cm — top of the back
Arm    = 62;  // cm — top of the arms, a step below the back
Seat   = 42;  // cm — seat height, top of the platform the legs carry

// printed mm / cm the arms and back rise off the seat platform
Seat_z = printed_h(Seat);
Arm_h  = Arm - Seat;
Back_h = Height - Seat;

// The frame under the seat, in real cm: four corner legs with the skirt between them set
// back, so it reads as a chair on legs (legged_2d in lib/common.scad). Chunkier than a
// dining chair's — a tub chair is a heavier piece.
Leg      = 14;  // cm — a corner leg, seen on both faces it turns ...
Leg_rail = 4;   // ... how far the skirt between two legs is set back behind them ...
Foot     = 16;  // ... and how tall the legs are (the open space under the seat body)

// The tub, in real cm: thick squared arms and a thick vertical back forming the U.
Arm_w  = 15;  // cm — arm thickness (side to side)
Back_d = 16;  // cm — back thickness (front to back)

Show_cushion = true;
Seat_rise    = 10;  // cm the seat cushion stands proud of the platform
Seat_gap     = 4;   // cm left around the seat cushion, from the arms and the front edge

Show_pillows = false;  // the boxy seat reads clean; turn on for a single throw pillow
Pillow_size  = 34;  // cm side of a throw pillow (a diamond from above); shrinks to fit
Pillow_rise  = 18;  // cm it stands proud of the seat platform

// One central magnet pocket in the bottom face: the piece is small and near-square, so a
// single pocket already stops it pivoting. It goes in the skirt, the broad part of the
// bottom face (legged_floor_w() and Magnet_* in lib/common.scad).
Magnets = 1;

// The leg height, clamped under the seat so a squashed chair keeps a body over its legs.
function foot_h() = min(Foot, Seat - 1);

armchair();

module armchair() {
    difference() {
        union() {
            seat_base();
            arms();
            back();
            if (Show_cushion) seat_cushion();
            if (Show_pillows) pillow_on_seat();
        }
        if (Magnets > 0)
            magnets(legged_floor_w(Width, Depth, Leg_rail),
                    legged_floor_d(Width, Depth, Leg_rail), Magnets);
    }
}

// The seat platform on four legs: the legged outline (corner posts + set-back skirt) for
// the bottom Foot cm, a 45 deg flare out to the full footprint, then a solid seat block
// up to Seat — a chunky box on short legs, every layer straight up or a 45 deg flare.
module seat_base() {
    fz = rise(foot_h());
    fl = min(cm(Leg_rail), fz - 0.2);         // flare height = the skirt set-back (45 deg)
    union() {
        linear_extrude(height = max(0.01, fz - fl) + 0.01)
            legged_2d(Width, Depth, Leg, Leg_rail);
        if (fl > 0)
            translate([0, 0, max(0.01, fz - fl)])
                flare(fl) {
                    legged_2d(Width, Depth, Leg, Leg_rail);
                    footprint_2d(Width, Depth);
                }
        translate([0, 0, fz - 0.01])
            linear_extrude(height = Seat_z - fz + 0.01)
                footprint_2d(Width, Depth);
    }
}

// Thick squared arms down each side, full depth, rising to Arm.
module arms() {
    for (s = [-1, 1])
        translate([s * cm(Width / 2 - Arm_w / 2), 0, Seat_z - 0.01])
            linear_extrude(height = rise(Arm_h) + 0.01)
                footprint_2d(Arm_w, Depth);
}

// A thick vertical back along the rear, full width so it wraps into the arms, rising to
// Height. Vertical, as a boxy tub chair's is — and a vertical wall needs no support.
module back() {
    translate([0, cm(Depth / 2 - Back_d / 2), Seat_z - 0.01])
        linear_extrude(height = rise(Back_h) + 0.01)
            footprint_2d(Width, Back_d);
}

// The seat cushion in the well between the arms and in front of the back, its back edge
// butting the back so the seat runs into it.
module seat_cushion() {
    fy = -Depth / 2 + Seat_gap;
    by = Depth / 2 - Back_d;
    translate([0, cm((fy + by) / 2), 0])
        cushion(Width - 2 * Arm_w - 2 * Seat_gap, by - fy, Seat_z, Seat_rise);
}

// One throw pillow against the back, shrunk to the well and dropped if it will not fit.
module pillow_on_seat() {
    fy   = -Depth / 2 + Seat_gap;
    by   = Depth / 2 - Back_d;
    w    = Width - 2 * Arm_w - 2 * Seat_gap;
    d    = by - fy;
    size = min(Pillow_size, min(w, d) / sqrt(2));
    half = size * sqrt(2) / 2;
    yp   = (fy + by) / 2 + d / 2 - half;
    if (size >= Symbol_min)
        translate([0, cm(yp), 0]) pillow(size, Seat_z, Pillow_rise);
    else
        echo(str("NOTE: no room for a throw pillow on a ", w, "x", d, " cm seat"));
}
