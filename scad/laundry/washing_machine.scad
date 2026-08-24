// laundry / washing_machine — a front-loader washing machine token: a round
// porthole door on its FRONT (-Y) face under a slim control fascia, with a detergent
// drawer tucked up on the left — the machine as you see it from across the room, not
// from directly above. The door, fascia and drawer are all cut into the front face;
// see appliance_front() in lib/common.scad.
//
// Width/Depth are the real-world footprint in cm: a standard front loader is 60x60,
// the same as a slot-in dishwasher or cooker. Height is the real height of the case
// — 85 cm, so it fits under a worktop — shrunk by the plan scale like the footprint
// (see printed_h() in lib/common.scad).
//
// The front is the -Y edge; rotate the piece on the board to face it into the room.

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 60;  // cm
Height = 85;  // cm — the case, under-worktop height

Print_h = printed_h(Height);   // printed height, mm — Height at the plan scale

// The door + fascia + detergent drawer on the front (-Y) face. See appliance_front()
// in lib/common.scad for the proportions.
Show_front = true;

// Magnet pockets in the bottom face (0 = none). Near-square, so one central pocket
// holds it down; at 1:40 a 60 cm side is 15 mm across — wide enough for a 4 mm disc.
Magnets = 1;

washing_machine();

module washing_machine() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_front)
            appliance_front(Width, Depth, 0, Print_h, drawer = true);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
