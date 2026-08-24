// outdoor / sofa — a garden couch token: the outdoor sibling of the living-room
// sofa (scad/livingroom/sofa.scad), with the same raised back cushion running
// the full width along the rear edge and an arm cushion down each short side.
//
// Width/Depth are the real-world footprint in cm — a 2-seat garden couch/bench.
// The heights are real cm, exactly as on the indoor sofa: Height is the top of the
// back, Arm the top of the arms and Seat the seat they rise from. The block is the
// seat (see printed_h() / rise() in lib/common.scad).

include <../lib/common.scad>

Width  = 140;  // cm — a 2-seat garden couch
Depth  = 70;   // cm
Height = 80;   // cm — top of the back cushion
Arm    = 60;   // cm — top of the arms
Seat   = 42;   // cm — seat height

// printed mm: the seat block the cushions stand on, and how far (cm) the back and
// the arms rise off it
Seat_z = printed_h(Seat);
Pad_h  = Height - Seat;
Arm_h  = Arm - Seat;

Show_cushions = true;
// Back and arm cushions, in real-world cm — unlike the armchair's, these run
// edge to edge: the back spans the full width and each arm the full depth, so
// the pads read as one wraparound seat back rather than three separate
// pillows, exactly as on the indoor sofa.
Back_d = 22;  // back cushion depth (front-to-back)
Arm_w  = 20;  // arm cushion width (side-to-side)

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two
// keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
Magnets = 2;

sofa();

module sofa() {
    union() {
        difference() {
            footprint(Width, Depth, Seat_z);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_cushions) {
            // back cushion: full width, along the rear edge
            translate([0, cm(Depth / 2 - Back_d / 2), 0])
                cushion(Width, Back_d, Seat_z, Pad_h);
            // an arm cushion down each side, running the full depth
            for (s = [-1, 1])
                translate([s * cm(Width / 2 - Arm_w / 2), 0, 0])
                    cushion(Arm_w, Depth, Seat_z, Arm_h);
        }
    }
}
