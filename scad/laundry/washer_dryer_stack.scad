// laundry / washer_dryer_stack — a stacked washer-dryer tower: the washing machine
// on the bottom and the tumble dryer on top, one 60x60 footprint carrying both. Two
// porthole doors on the FRONT (-Y) face — the lower one with a detergent drawer (the
// washer), the upper one without (the dryer) — split by a seam groove where the two
// cases meet. The doors, fascias, drawer and seam are all cut into the front face;
// see appliance_front() in lib/common.scad.
//
// Width/Depth are the real-world footprint in cm: 60x60, a single machine's. Height
// is the real height of the whole tower — two 85 cm cases, so 170 cm — shrunk by the
// plan scale like the footprint (see printed_h() in lib/common.scad). The two cases
// are equal, so the seam sits at half the printed height.
//
// The front is the -Y edge; rotate the piece on the board to face it into the room.

include <../lib/common.scad>

Width  = 60;   // cm
Depth  = 60;   // cm
Height = 170;  // cm — the whole tower: a washer case plus a dryer case

Print_h = printed_h(Height);   // printed height, mm — Height at the plan scale
Seam_z  = Print_h / 2;         // printed mm up the front where the two cases meet

// The two doors + fascias + the washer's drawer + the seam, on the front (-Y) face.
// See appliance_front() in lib/common.scad for the proportions.
Show_front = true;

// Magnet pockets in the bottom face (0 = none). A tall, narrow tower — two pockets
// keep it from pivoting; see Magnet_* in lib/common.scad.
Magnets = 2;

washer_dryer_stack();

module washer_dryer_stack() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_front) {
            appliance_front(Width, Depth, 0, Seam_z, drawer = true);        // washer
            appliance_front(Width, Depth, Seam_z, Print_h, drawer = false); // dryer
            // the seam where the two cases butt together
            front_recess(0, Seam_z, cm(Width - 4), rise(1.5), Depth);
        }
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
